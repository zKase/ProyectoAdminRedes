import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class ChatbotService {
  constructor(private configService: ConfigService) {}

  async ask(message: string) {
    const apiKey = this.configService.get<string>('OPENROUTER_API_KEY');
    const model = this.configService.get<string>('OPENROUTER_MODEL', 'mistralai/mistral-7b-instruct:free');

    if (!apiKey) {
      return {
        mode: 'local',
        answer: this.localAnswer(message),
      };
    }

    const response = await fetch('https://openrouter.ai/api/v1/chat/completions', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${apiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model,
        messages: [
          {
            role: 'system',
            content: 'Eres un asistente municipal para una plataforma de participación ciudadana. Responde breve, claro y en español.',
          },
          { role: 'user', content: message },
        ],
      }),
    });

    if (!response.ok) {
      return {
        mode: 'fallback',
        answer: this.localAnswer(message),
      };
    }

    const data = await response.json();
    return {
      mode: 'openrouter',
      answer: data?.choices?.[0]?.message?.content ?? this.localAnswer(message),
    };
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
