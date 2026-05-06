import { Controller, Get, Post, Body, Patch, Param } from '@nestjs/common';
import { ProposalsService } from './proposals.service';
import { CreateProposalDto } from './dto/create-proposal.dto';

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
  vote(@Param('id') id: string) {
    return this.proposalsService.vote(id);
  }
}
