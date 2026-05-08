import { Body, Controller, Post } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { ChatbotService } from './chatbot.service';
import { ChatbotMessageDto } from './dto/chatbot.dto';

@ApiTags('chatbot')
@Controller('chatbot')
@ApiBearerAuth()
export class ChatbotController {
  constructor(private chatbotService: ChatbotService) {}

  @ApiOperation({ summary: 'Enviar pregunta al asistente ciudadano' })
  @Post('ask')
  async ask(@Body() dto: ChatbotMessageDto) {
    return this.chatbotService.ask(dto.message);
  }
}
