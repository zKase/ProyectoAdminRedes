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

  @ApiOperation({ summary: 'Register a new citizen' })
  @Public()
  @Post('register')
  async register(@Body() registerDto: RegisterDto) {
    return this.usersService.register(registerDto);
  }

  @ApiOperation({ summary: 'Login user' })
  @Public()
  @Post('login')
  async login(@Body() loginDto: LoginDto) {
    return this.usersService.login(loginDto);
  }

  @ApiOperation({ summary: 'Get current user profile' })
  @ApiBearerAuth()
  @Get('profile')
  async getProfile(@Request() req) {
    return this.usersService.findById(req.user.userId);
  }

  @ApiOperation({ summary: 'Get user by ID' })
  @ApiBearerAuth()
  @Get('users/:id')
  async getUserById(@Param('id') id: string) {
    return this.usersService.findById(id);
  }

  @ApiOperation({ summary: 'Get all users (Admin only)' })
  @ApiBearerAuth()
  @Roles(UserRole.ADMIN)
  @Get('users')
  async getAllUsers(@Request() req) {
    return this.usersService.findAll();
  }
}
