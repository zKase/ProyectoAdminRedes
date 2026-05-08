import {
  Injectable,
  ConflictException,
  UnauthorizedException,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { User, UserRole } from './entities/user.entity';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private usersRepository: Repository<User>,
    private jwtService: JwtService,
  ) {}

  /**
   * Registra un nuevo usuario ciudadano
   */
  async register(registerDto: RegisterDto) {
    const { email, password, firstName, lastName } = registerDto;

    // Verificar que el email no exista
    const existingUser = await this.usersRepository.findOneBy({ email });
    if (existingUser) {
      throw new ConflictException('El correo electrónico ya está registrado');
    }

    // Hash de la contraseña
    const hashedPassword = await bcrypt.hash(password, 10);

    // Crear usuario con rol CITIZEN por defecto
    const user = this.usersRepository.create({
      email,
      password: hashedPassword,
      firstName,
      lastName,
      role: UserRole.CITIZEN,
    });

    const savedUser = await this.usersRepository.save(user);

    // Generar token JWT
    const token = this.jwtService.sign({
      sub: savedUser.id,
      role: savedUser.role,
    });

    return {
      message: 'Usuario registrado correctamente',
      user: {
        id: savedUser.id,
        email: savedUser.email,
        firstName: savedUser.firstName,
        lastName: savedUser.lastName,
        role: savedUser.role,
      },
      token,
    };
  }

  /**
   * Login de usuario
   */
  async login(loginDto: LoginDto) {
    const { email, password } = loginDto;

    // Buscar usuario por email
    const user = await this.usersRepository.findOneBy({ email });
    if (!user) {
      throw new UnauthorizedException('Credenciales inválidas');
    }

    // Verificar contraseña
    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      throw new UnauthorizedException('Credenciales inválidas');
    }

    // Verificar que el usuario esté activo
    if (!user.isActive) {
      throw new UnauthorizedException('La cuenta de usuario está inactiva');
    }

    // Generar token JWT
    const token = this.jwtService.sign({
      sub: user.id,
      role: user.role,
    });

    return {
      message: 'Inicio de sesión correcto',
      user: {
        id: user.id,
        email: user.email,
        firstName: user.firstName,
        lastName: user.lastName,
        role: user.role,
      },
      token,
    };
  }

  /**
   * Obtener usuario por ID
   */
  async findById(id: string) {
    const user = await this.usersRepository.findOneBy({ id });
    if (!user) {
      throw new NotFoundException('Usuario no encontrado');
    }
    // No retornar contraseña
    const { password, ...userWithoutPassword } = user;
    return userWithoutPassword;
  }

  /**
   * Obtener todos los usuarios (solo para admins)
   */
  async findAll() {
    const users = await this.usersRepository.find();
    // Retornar sin contraseñas
    return users.map(({ password, ...user }) => user);
  }

  /**
   * Crear un usuario con rol específico (solo para admins)
   */
  async createUserWithRole(
    registerDto: RegisterDto,
    role: UserRole,
  ) {
    const { email, password, firstName, lastName } = registerDto;

    // Verificar que el email no exista
    const existingUser = await this.usersRepository.findOneBy({ email });
    if (existingUser) {
      throw new ConflictException('El correo electrónico ya está registrado');
    }

    // Hash de la contraseña
    const hashedPassword = await bcrypt.hash(password, 10);

    // Crear usuario con rol especificado
    const user = this.usersRepository.create({
      email,
      password: hashedPassword,
      firstName,
      lastName,
      role,
    });

    const savedUser = await this.usersRepository.save(user);
    const { password: _, ...userWithoutPassword } = savedUser;

    return {
      message: `Usuario creado correctamente con rol ${role}`,
      user: userWithoutPassword,
    };
  }

  /**
   * Cambiar rol de usuario (solo para admins)
   */
  async updateUserRole(userId: string, newRole: UserRole) {
    const user = await this.usersRepository.findOneBy({ id: userId });
    if (!user) {
      throw new NotFoundException('Usuario no encontrado');
    }

    user.role = newRole;
    const updatedUser = await this.usersRepository.save(user);
    const { password, ...userWithoutPassword } = updatedUser;

    return {
      message: 'Rol de usuario actualizado correctamente',
      user: userWithoutPassword,
    };
  }

  /**
   * Desactivar usuario
   */
  async deactivateUser(userId: string) {
    const user = await this.usersRepository.findOneBy({ id: userId });
    if (!user) {
      throw new NotFoundException('Usuario no encontrado');
    }

    user.isActive = false;
    await this.usersRepository.save(user);

    return { message: 'Usuario desactivado correctamente' };
  }
}
