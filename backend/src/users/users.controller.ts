import {
  Controller,
  Post,
  Get,
  Body,
  Param,
  Request,
} from '@nestjs/common';
import { ApiBearerAuth, ApiTags, ApiOperation } from '@nestjs/swagger';
import { UsersService } from './users.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { Public } from '../guards/public.decorator';
import { Roles } from '../guards/roles.decorator';
import { UserRole } from './entities/user.entity';

@ApiTags('auth')
@Controller('auth')
export class UsersController {
  constructor(private usersService: UsersService) {}

  @ApiOperation({ summary: 'Registrar un nuevo ciudadano' })
  @Public()
  @Post('register')
  async register(@Body() registerDto: RegisterDto) {
    return this.usersService.register(registerDto);
  }

  @ApiOperation({ summary: 'Iniciar sesión de usuario' })
  @Public()
  @Post('login')
  async login(@Body() loginDto: LoginDto) {
    return this.usersService.login(loginDto);
  }

  @ApiOperation({ summary: 'Obtener el perfil del usuario actual' })
  @ApiBearerAuth()
  @Get('profile')
  async getProfile(@Request() req) {
    return this.usersService.findById(req.user.userId);
  }

  @ApiOperation({ summary: 'Obtener usuario por ID' })
  @ApiBearerAuth()
  @Get('users/:id')
  async getUserById(@Param('id') id: string) {
    return this.usersService.findById(id);
  }

  @ApiOperation({ summary: 'Obtener todos los usuarios (solo Admin)' })
  @ApiBearerAuth()
  @Roles(UserRole.ADMIN)
  @Get('users')
  async getAllUsers(@Request() req) {
    return this.usersService.findAll();
  }
}
