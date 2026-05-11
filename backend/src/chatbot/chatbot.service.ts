import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { HttpService } from '@nestjs/axios';
import { firstValueFrom } from 'rxjs';

@Injectable()
export class ChatbotService {
  private readonly logger = new Logger(ChatbotService.name);

  constructor(
    private configService: ConfigService,
    private httpService: HttpService,
  ) {}

  async ask(message: string) {
    const apiKey = this.configService.get<string>('OPENROUTER_API_KEY');
    const model = this.configService.get<string>('OPENROUTER_MODEL', 'google/gemini-2.0-flash-001');

    if (!apiKey) {
      this.logger.warn('OPENROUTER_API_KEY not set. Using fallback.');
      return {
        mode: 'local',
        answer: this.localAnswer(message),
      };
    }

    const systemPrompt = 'Eres un asistente virtual de la Municipalidad de Las Condes, experto en participación ciudadana, leyes locales y resolución de dudas sobre propuestas y presupuestos. Tu tono es profesional, servicial y empresarial.';

    try {
      const { data } = await firstValueFrom(
        this.httpService.post(
          'https://openrouter.ai/api/v1/chat/completions',
          {
            model,
            messages: [
              { role: 'system', content: systemPrompt },
              { role: 'user', content: message },
            ],
          },
          {
            headers: {
              Authorization: `Bearer ${apiKey}`,
              'Content-Type': 'application/json',
              'HTTP-Referer': 'http://localhost:4200',
              'X-Title': 'Municipalidad de Las Condes',
            },
          },
        ),
      );

      return {
        mode: 'openrouter',
        answer: data?.choices?.[0]?.message?.content ?? this.localAnswer(message),
      };
    } catch (error) {
      this.logger.error('Error calling OpenRouter API', error);
      return {
        mode: 'fallback',
        answer: this.localAnswer(message),
      };
    }
  }

  private localAnswer(message: string): string {
    const normalized = message.toLowerCase();

    if (normalized.includes('votar') || normalized.includes('presupuesto')) {
      return 'Para votar en un presupuesto participativo, ingresa a la sección Presupuestos, revisa los proyectos disponibles y presiona Votar en la alternativa que prefieras.';
    }

    if (normalized.includes('encuesta') || normalized.includes('consulta')) {
      return 'Para participar en una consulta o encuesta, abre la sección Encuestas y responde las preguntas disponibles. Algunas preguntas pueden aparecer según tus respuestas anteriores.';
    }

    if (normalized.includes('propuesta')) {
      return 'Para publicar una propuesta, completa el título, la categoría y una descripción clara. Luego podrás recibir votos y comentarios de otros participantes.';
    }

    if (normalized.includes('mapa') || normalized.includes('problemática') || normalized.includes('ubicación')) {
      return 'Para reportar una problemática territorial, usa la sección Mapeo Participativo e indica título, categoría, descripción y ubicación aproximada.';
    }

    return 'Puedo ayudarte con propuestas, encuestas, presupuestos participativos y problemáticas territoriales. Indica qué acción deseas realizar.';
  }
}
