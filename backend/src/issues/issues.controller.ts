import { Body, Controller, Delete, Get, Param, Patch, Post, Query, Request } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { Roles } from '../guards/roles.decorator';
import { UserRole } from '../users/entities/user.entity';
import { CreateIssueDto, UpdateIssueDto } from './dto/issue.dto';
import { IssueStatus } from './entities/issue.entity';
import { IssuesService } from './issues.service';

@ApiTags('issues')
@Controller('issues')
@ApiBearerAuth()
export class IssuesController {
  constructor(private issuesService: IssuesService) {}

  @ApiOperation({ summary: 'Crear problemática territorial' })
  @Post()
  async create(@Body() createIssueDto: CreateIssueDto, @Request() req) {
    return this.issuesService.create(createIssueDto, req.user.userId);
  }

  @ApiOperation({ summary: 'Listar problemáticas territoriales' })
  @Get()
  async findAll(@Query('status') status?: IssueStatus) {
    return this.issuesService.findAll(status);
  }

  @ApiOperation({ summary: 'Obtener problemática territorial por ID' })
  @Get(':id')
  async findById(@Param('id') id: string) {
    return this.issuesService.findById(id);
  }

  @ApiOperation({ summary: 'Actualizar problemática territorial (Admin/Moderador)' })
  @Roles(UserRole.ADMIN, UserRole.MODERATOR)
  @Patch(':id')
  async update(@Param('id') id: string, @Body() updateIssueDto: UpdateIssueDto) {
    return this.issuesService.update(id, updateIssueDto);
  }

  @ApiOperation({ summary: 'Cambiar estado de problemática territorial (Admin/Moderador)' })
  @Roles(UserRole.ADMIN, UserRole.MODERATOR)
  @Patch(':id/status/:status')
  async updateStatus(@Param('id') id: string, @Param('status') status: IssueStatus) {
    return this.issuesService.updateStatus(id, status);
  }

  @ApiOperation({ summary: 'Eliminar problemática territorial (Admin/Moderador)' })
  @Roles(UserRole.ADMIN, UserRole.MODERATOR)
  @Delete(':id')
  async remove(@Param('id') id: string) {
    return this.issuesService.remove(id);
  }
}
