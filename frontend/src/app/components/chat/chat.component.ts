import { Component, ElementRef, ViewChild, effect, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ChatService } from '../../services/chat.service';
import { ToastService } from '../../services/toast.service';

@Component({
  selector: 'app-chat',
  standalone: true,
  imports: [CommonModule, FormsModule],
  template: `
    <div class="flex flex-col h-[calc(100vh-12rem)] max-h-[800px] w-full max-w-4xl mx-auto rounded-2xl shadow-xl overflow-hidden bg-surface-container-lowest border border-outline-variant/50">
      
      <!-- Header -->
      <header class="bg-gradient-to-r from-[#0F172A] to-[#1E293B] px-6 py-4 flex items-center justify-between shadow-md z-10">
        <div class="flex items-center gap-3">
          <div class="w-10 h-10 rounded-full bg-white/10 flex items-center justify-center border border-white/20">
            <span class="material-symbols-outlined text-white text-[20px]">smart_toy</span>
          </div>
          <div>
            <h2 class="text-white font-bold text-lg leading-tight">Asistente Municipal</h2>
            <p class="text-slate-300 text-xs font-medium tracking-wide flex items-center gap-1">
              <span class="w-1.5 h-1.5 rounded-full bg-green-400"></span> En línea
            </p>
          </div>
        </div>
      </header>

      <!-- Messages Area -->
      <div #scrollContainer class="flex-1 overflow-y-auto p-6 flex flex-col gap-5 bg-slate-50 dark:bg-transparent">
        @if (chatService.messages().length === 0) {
          <div class="flex-1 flex flex-col items-center justify-center text-center opacity-70">
            <span class="material-symbols-outlined text-5xl text-slate-400 mb-3">forum</span>
            <p class="text-slate-500 font-medium">¡Hola! Soy tu asistente virtual de Las Condes.</p>
            <p class="text-slate-400 text-sm">Pregúntame sobre propuestas, presupuestos o leyes locales.</p>
          </div>
        }

        @for (msg of chatService.messages(); track msg.id) {
          <div class="flex w-full" [ngClass]="msg.role === 'user' ? 'justify-end' : 'justify-start'">
            <div class="max-w-[85%] sm:max-w-[75%] rounded-2xl px-5 py-3 shadow-sm relative group"
                 [ngClass]="msg.role === 'user' 
                  ? 'bg-gradient-to-br from-[#1E293B] to-[#334155] text-white rounded-tr-sm' 
                  : 'bg-white dark:bg-[#1E293B] text-slate-800 dark:text-slate-200 border border-slate-200 dark:border-slate-700 rounded-tl-sm'">
              
              <div class="font-body whitespace-pre-wrap leading-relaxed">{{ msg.content }}</div>
              
              <div class="text-[10px] mt-1 opacity-60 text-right" [ngClass]="msg.role === 'user' ? 'text-slate-300' : 'text-slate-500 dark:text-slate-400'">
                {{ msg.timestamp | date:'shortTime' }}
              </div>
            </div>
          </div>
        }

        @if (isLoading()) {
          <div class="flex w-full justify-start">
            <div class="bg-white dark:bg-[#1E293B] border border-slate-200 dark:border-slate-700 rounded-2xl rounded-tl-sm px-5 py-4 shadow-sm flex items-center gap-2">
              <div class="w-2 h-2 rounded-full bg-slate-400 animate-bounce"></div>
              <div class="w-2 h-2 rounded-full bg-slate-400 animate-bounce" style="animation-delay: 0.15s"></div>
              <div class="w-2 h-2 rounded-full bg-slate-400 animate-bounce" style="animation-delay: 0.3s"></div>
            </div>
          </div>
        }
      </div>

      <!-- Input Area -->
      <div class="p-4 bg-white dark:bg-surface-container border-t border-slate-200 dark:border-slate-700/50">
        <form (ngSubmit)="sendMessage()" class="relative flex items-center">
          <input 
            #messageInput
            type="text" 
            [(ngModel)]="newMessage" 
            name="message" 
            placeholder="Escribe tu consulta aquí..." 
            class="w-full pl-5 pr-14 py-4 rounded-xl border border-slate-200 dark:border-slate-600 bg-slate-50 dark:bg-surface-container-lowest text-slate-800 dark:text-slate-100 placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-[#1E293B] dark:focus:ring-slate-400 focus:border-transparent transition-all shadow-inner"
            [disabled]="isLoading()"
            autocomplete="off"
            required>
          
          <button 
            type="submit" 
            [disabled]="isLoading() || !newMessage.trim()"
            class="absolute right-2 w-10 h-10 rounded-lg bg-[#1E293B] hover:bg-[#0F172A] text-white flex items-center justify-center transition-colors disabled:opacity-50 disabled:cursor-not-allowed cursor-pointer active:scale-95 shadow-md">
            <span class="material-symbols-outlined text-[20px] ml-1">send</span>
          </button>
        </form>
      </div>
    </div>
  `
})
export class ChatComponent {
  chatService = inject(ChatService);
  private toast = inject(ToastService);

  @ViewChild('scrollContainer') private scrollContainer!: ElementRef;
  @ViewChild('messageInput') private messageInput!: ElementRef;

  newMessage = '';
  isLoading = signal(false);

  constructor() {
    effect(() => {
      // Trigger scroll down whenever messages change
      const msgs = this.chatService.messages();
      setTimeout(() => this.scrollToBottom(), 50);
    });
  }

  sendMessage() {
    const text = this.newMessage.trim();
    if (!text || this.isLoading()) return;

    this.chatService.addMessage('user', text);
    this.newMessage = '';
    this.isLoading.set(true);

    this.chatService.ask(text).subscribe({
      next: (res) => {
        this.chatService.addMessage('assistant', res.answer);
        this.isLoading.set(false);
        setTimeout(() => this.messageInput?.nativeElement?.focus(), 50);
      },
      error: (err) => {
        this.toast.error('Error al conectar con el asistente');
        this.isLoading.set(false);
        console.error(err);
      }
    });
  }

  private scrollToBottom(): void {
    try {
      if (this.scrollContainer) {
        this.scrollContainer.nativeElement.scrollTop = this.scrollContainer.nativeElement.scrollHeight;
      }
    } catch(err) { }
  }
}
