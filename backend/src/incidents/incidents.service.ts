import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Incident } from './entities/incident.entity';

@Injectable()
export class IncidentsService {
  constructor(
    @InjectRepository(Incident)
    private readonly incidentRepository: Repository<Incident>,
  ) {}

  async findAll(): Promise<Incident[]> {
    return this.incidentRepository.find({
      order: { createdAt: 'DESC' },
    });
  }

  async findOne(id: string): Promise<Incident> {
    const incident = await this.incidentRepository.findOne({ where: { id } });
    if (!incident) {
      throw new NotFoundException(`Incident with ID ${id} not found`);
    }
    return incident;
  }

  async create(createDto: any, user: any): Promise<Incident> {
    const incident = this.incidentRepository.create({
      ...createDto,
      reporter: user,
      dateReported: new Date().toISOString(),
    });
    // We use 'as any' to bypass the complex TypeORM overloads that confuse TypeScript
    return this.incidentRepository.save(incident as any);
  }

  async update(id: string, updateDto: any): Promise<Incident> {
    const incident = await this.findOne(id);
    Object.assign(incident, updateDto);
    if (updateDto.status === 'Resolved' && !incident.resolvedAt) {
      incident.resolvedAt = new Date();
    }
    return this.incidentRepository.save(incident as any);
  }

  async remove(id: string): Promise<void> {
    const incident = await this.findOne(id);
    await this.incidentRepository.remove(incident);
  }
}
