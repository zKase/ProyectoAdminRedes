import { Body, Controller, Post, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../guards/jwt-auth.guard';
import { ChatbotService } from './chatbot.service';
import { ChatbotMessageDto } from './dto/chatbot.dto';

@ApiTags('chat')
@Controller('chat')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
export class ChatbotController {
  constructor(private chatbotService: ChatbotService) {}

  @ApiOperation({ summary: 'Enviar pregunta al asistente ciudadano' })
  @Post('ask')
  async ask(@Body() dto: ChatbotMessageDto) {
    return this.chatbotService.ask(dto.message);
  }
}
