import { Controller, Get, Post, Body, Patch, Param, Query, Request, Delete } from '@nestjs/common';
import { ProposalsService } from './proposals.service';
import { CreateProposalDto } from './dto/create-proposal.dto';
import { CreateProposalCommentDto, UpdateProposalCommentDto } from './dto/proposal-comment.dto';
import { Roles } from '../guards/roles.decorator';
import { UserRole } from '../users/entities/user.entity';

@Controller('proposals')
export class ProposalsController {
  constructor(private readonly proposalsService: ProposalsService) {}

  @Post()
  create(@Body() createProposalDto: CreateProposalDto) {
    return this.proposalsService.create(createProposalDto);
  }

  @Get()
  findAll() {
    return this.proposalsService.findAll();
  }

  @Patch(':id/vote')
  vote(@Param('id') id: string, @Request() req) {
    return this.proposalsService.vote(id, req.user.userId);
  }

  @Post(':id/comments')
  addComment(
    @Param('id') id: string,
    @Body() dto: CreateProposalCommentDto,
    @Request() req,
  ) {
    return this.proposalsService.addComment(id, dto, req.user.userId);
  }

  @Get(':id/comments')
  findComments(@Param('id') id: string, @Query('includeHidden') includeHidden?: string) {
    return this.proposalsService.findComments(id, includeHidden === 'true');
  }

  @Roles(UserRole.ADMIN, UserRole.MODERATOR)
  @Patch('comments/:commentId')
  updateComment(
    @Param('commentId') commentId: string,
    @Body() dto: UpdateProposalCommentDto,
  ) {
    return this.proposalsService.updateComment(commentId, dto);
  }

  @Roles(UserRole.ADMIN, UserRole.MODERATOR)
  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.proposalsService.remove(id);
  }
}
