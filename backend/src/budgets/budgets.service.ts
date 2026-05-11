import {
  Injectable,
  NotFoundException,
  ConflictException,
  BadRequestException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Budget, BudgetStatus } from './entities/budget.entity';
import { BudgetItem } from './entities/budget-item.entity';
import { BudgetVote } from './entities/budget-vote.entity';
import { CreateBudgetDto, UpdateBudgetDto, CreateBudgetItemDto, VoteBudgetItemDto } from './dto/budget.dto';

@Injectable()
export class BudgetsService {
  constructor(
    @InjectRepository(Budget)
    private budgetsRepository: Repository<Budget>,
    @InjectRepository(BudgetItem)
    private itemsRepository: Repository<BudgetItem>,
    @InjectRepository(BudgetVote)
    private votesRepository: Repository<BudgetVote>,
  ) {}

  /**
   * Crear un nuevo presupuesto participativo
   */
  async create(createBudgetDto: CreateBudgetDto, userId: string): Promise<Budget> {
    const { items, ...budgetData } = createBudgetDto;

    const budget = this.budgetsRepository.create({
      ...budgetData,
      createdBy: userId,
    });

    const savedBudget = await this.budgetsRepository.save(budget);

    // Crear items si existen
    if (items && items.length > 0) {
      for (const itemDto of items) {
        await this.addItem(savedBudget.id, itemDto);
      }
    }

    return this.findById(savedBudget.id);
  }

  /**
   * Obtener todos los presupuestos
   */
  async findAll(status?: BudgetStatus): Promise<Budget[]> {
    const query = this.budgetsRepository.createQueryBuilder('budget');

    if (status) {
      query.where('budget.status = :status', { status });
    }

    return query.orderBy('budget.createdAt', 'DESC').getMany();
  }

  /**
   * Obtener presupuesto por ID
   */
  async findById(id: string): Promise<Budget> {
    const budget = await this.budgetsRepository
      .createQueryBuilder('budget')
      .leftJoinAndSelect('budget.items', 'items')
      .leftJoinAndSelect('budget.creator', 'creator')
      .where('budget.id = :id', { id })
      .getOne();

    if (!budget) {
      throw new NotFoundException('Budget not found');
    }

    return budget;
  }

  /**
   * Actualizar presupuesto
   */
  async update(id: string, updateBudgetDto: UpdateBudgetDto): Promise<Budget> {
    const budget = await this.findById(id);

    Object.assign(budget, updateBudgetDto);

    await this.budgetsRepository.save(budget);

    return this.findById(id);
  }

  /**
   * Cambiar estado del presupuesto
   */
  async updateStatus(id: string, status: BudgetStatus): Promise<Budget> {
    const budget = await this.findById(id);

    budget.status = status;

    await this.budgetsRepository.save(budget);

    return this.findById(id);
  }

  /**
   * Agregar item al presupuesto
   */
  async addItem(budgetId: string, createItemDto: CreateBudgetItemDto): Promise<BudgetItem> {
    const budget = await this.findById(budgetId);

    const item = this.itemsRepository.create({
      ...createItemDto,
      budgetId,
    });

    return this.itemsRepository.save(item);
  }

  /**
   * Obtener items de un presupuesto
   */
  async getItems(budgetId: string): Promise<BudgetItem[]> {
    return this.itemsRepository.find({
      where: { budgetId, isActive: true },
      order: { title: 'ASC' },
    });
  }

  /**
   * Votar por un item del presupuesto
   * RNF01: Prevenir duplicidad de votos (un voto por usuario por item)
   */
  async voteItem(
    budgetId: string,
    voteBudgetItemDto: VoteBudgetItemDto,
    userId: string,
  ): Promise<{ message: string; voteCount: number }> {
    const budget = await this.findById(budgetId);

    if (budget.status !== BudgetStatus.ACTIVE) {
      throw new BadRequestException('Budget voting is not active');
    }

    const item = await this.itemsRepository.findOneBy({
      id: voteBudgetItemDto.itemId,
      budgetId,
    });

    if (!item) {
      throw new NotFoundException('Budget item not found');
    }

    // Solo se permite un voto por presupuesto (una vez por publicación)
    const hasVotedInBudget = await this.votesRepository.findOne({
      where: { budgetId, userId },
    });

    if (hasVotedInBudget) {
      throw new ConflictException('User can only vote once in this budget');
    }

    // Registrar el voto
    const vote = this.votesRepository.create({
      budgetId,
      itemId: voteBudgetItemDto.itemId,
      userId,
    });

    await this.votesRepository.save(vote);

    // Incrementar contador de votos del item
    item.voteCount += 1;
    await this.itemsRepository.save(item);

    // Actualizar contador de participantes
    const uniqueVoters = await this.votesRepository
      .createQueryBuilder('vote')
      .select('COUNT(DISTINCT vote.userId)', 'count')
      .where('vote.budgetId = :budgetId', { budgetId })
      .getRawOne();

    budget.participantsCount = parseInt(uniqueVoters.count) || 0;
    await this.budgetsRepository.save(budget);

    return {
      message: 'Vote registered successfully',
      voteCount: item.voteCount,
    };
  }

  /**
   * Obtener resultados del presupuesto participativo
   */
  async getBudgetResults(budgetId: string): Promise<any> {
    const budget = await this.findById(budgetId);
    const items = budget.items;

    const totalVotes = await this.votesRepository.count({
      where: { budgetId },
    });

    const itemsWithPercentage = items.map((item) => ({
      id: item.id,
      title: item.title,
      description: item.description,
      estimatedCost: item.estimatedCost,
      votes: item.voteCount,
      percentage: totalVotes > 0 ? ((item.voteCount / totalVotes) * 100).toFixed(2) : 0,
    }));

    return {
      budgetId,
      title: budget.title,
      totalAmount: budget.totalAmount,
      allocatedAmount: budget.allocatedAmount,
      participantsCount: budget.participantsCount,
      totalVotes,
      items: itemsWithPercentage.sort((a, b) => b.votes - a.votes),
    };
  }

  /**
   * Eliminar presupuesto
   */
  async delete(id: string): Promise<void> {
    const budget = await this.findById(id);
    await this.budgetsRepository.remove(budget);
  }

  /**
   * Obtener votos del usuario en un presupuesto
   */
  async getUserVotes(budgetId: string, userId: string): Promise<BudgetVote[]> {
    return this.votesRepository.find({
      where: { budgetId, userId },
      relations: ['item'],
    });
  }
}
