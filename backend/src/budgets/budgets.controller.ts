import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Body,
  Param,
  Query,
  Request,
} from '@nestjs/common';
import { ApiBearerAuth, ApiTags, ApiOperation } from '@nestjs/swagger';
import { BudgetsService } from './budgets.service';
import { CreateBudgetDto, UpdateBudgetDto, VoteBudgetItemDto } from './dto/budget.dto';
import { Roles } from '../guards/roles.decorator';
import { UserRole } from '../users/entities/user.entity';

@ApiTags('budgets')
@Controller('budgets')
@ApiBearerAuth()
export class BudgetsController {
  constructor(private budgetsService: BudgetsService) {}

  @ApiOperation({ summary: 'Create a new budget (Admin/Moderator only)' })
  @Roles(UserRole.ADMIN, UserRole.MODERATOR)
  @Post()
  async create(@Body() createBudgetDto: CreateBudgetDto, @Request() req) {
    return this.budgetsService.create(createBudgetDto, req.user.userId);
  }

  @ApiOperation({ summary: 'Get all budgets' })
  @Get()
  async findAll(@Query('status') status?: string) {
    return this.budgetsService.findAll(status as any);
  }

  @ApiOperation({ summary: 'Get budget by ID' })
  @Get(':id')
  async findById(@Param('id') id: string) {
    return this.budgetsService.findById(id);
  }

  @ApiOperation({ summary: 'Update budget (Admin/Moderator only)' })
  @Roles(UserRole.ADMIN, UserRole.MODERATOR)
  @Patch(':id')
  async update(
    @Param('id') id: string,
    @Body() updateBudgetDto: UpdateBudgetDto,
  ) {
    return this.budgetsService.update(id, updateBudgetDto);
  }

  @ApiOperation({ summary: 'Change budget status (Admin only)' })
  @Roles(UserRole.ADMIN)
  @Patch(':id/status/:status')
  async updateStatus(@Param('id') id: string, @Param('status') status: string) {
    return this.budgetsService.updateStatus(id, status as any);
  }

  @ApiOperation({ summary: 'Delete budget (Admin only)' })
  @Roles(UserRole.ADMIN)
  @Delete(':id')
  async delete(@Param('id') id: string) {
    await this.budgetsService.delete(id);
    return { message: 'Budget deleted successfully' };
  }

  @ApiOperation({ summary: 'Vote for a budget item' })
  @Post(':id/vote')
  async voteItem(
    @Param('id') id: string,
    @Body() voteBudgetItemDto: VoteBudgetItemDto,
    @Request() req,
  ) {
    return this.budgetsService.voteItem(id, voteBudgetItemDto, req.user.userId);
  }

  @ApiOperation({ summary: 'Get budget results with statistics' })
  @Get(':id/results')
  async getBudgetResults(@Param('id') id: string) {
    return this.budgetsService.getBudgetResults(id);
  }

  @ApiOperation({ summary: 'Get user votes in a budget' })
  @Get(':id/user-votes')
  async getUserVotes(@Param('id') id: string, @Request() req) {
    return this.budgetsService.getUserVotes(id, req.user.userId);
  }
}
