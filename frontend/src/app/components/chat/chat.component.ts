import { Component, ElementRef, ViewChild, effect, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ChatService } from '../../services/chat.service';
import { ToastService } from '../../services/toast.service';
import { DomSanitizer, SafeHtml } from '@angular/platform-browser';

@Component({
  selector: 'app-chat',
  standalone: true,
  imports: [CommonModule, FormsModule],
  template: `
    <!-- Floating Chat Button (Bubble) -->
    <button 
      *ngIf="!isOpen()" 
      (click)="toggleChat()"
      class="fixed bottom-8 right-8 w-16 h-16 rounded-full bg-gradient-to-br from-primary to-[#4F46E5] text-white shadow-[0_10px_40px_rgba(var(--primary),0.4)] flex items-center justify-center hover:scale-110 active:scale-95 transition-all duration-300 z-50 group border-2 border-white/20">
      <span class="material-symbols-outlined text-[36px] group-hover:rotate-12 transition-transform" style="font-variation-settings: 'FILL' 1">smart_toy</span>
      <span class="absolute -top-1 -right-1 w-6 h-6 bg-error text-white rounded-full border-2 border-white flex items-center justify-center text-[11px] font-bold shadow-lg" *ngIf="hasNewMessages()">1</span>
    </button>

    <!-- Messenger Style Chat Window -->
    <div 
      *ngIf="isOpen()"
      class="fixed bottom-6 right-6 w-[95vw] sm:w-[420px] h-[650px] max-h-[85vh] bg-white dark:bg-[#1E293B] rounded-3xl shadow-[0_20px_50px_rgba(0,0,0,0.3)] flex flex-col overflow-hidden z-50 animate-in slide-in-from-bottom-10 duration-300 border border-slate-100 dark:border-slate-800">
      
      <!-- Messenger Header -->
      <header class="px-5 py-4 bg-white dark:bg-[#1E293B] border-b border-slate-100 dark:border-slate-800 flex items-center justify-between shadow-sm">
        <div class="flex items-center gap-3">
          <div class="relative">
            <div class="w-10 h-10 rounded-full bg-primary/10 flex items-center justify-center">
              <span class="material-symbols-outlined text-primary">smart_toy</span>
            </div>
            <span class="absolute bottom-0 right-0 w-3 h-3 bg-green-500 border-2 border-white dark:border-[#1E293B] rounded-full"></span>
          </div>
          <div>
            <h3 class="font-bold text-slate-800 dark:text-white text-sm leading-tight">Asistente Municipal</h3>
            <p class="text-[11px] text-slate-400 font-medium">Activo ahora</p>
          </div>
        </div>
        <div class="flex items-center gap-1">
          <button (click)="toggleChat()" class="p-2 hover:bg-slate-100 dark:hover:bg-slate-800 rounded-full text-slate-400 transition-colors">
            <span class="material-symbols-outlined text-[20px]">close</span>
          </button>
        </div>
      </header>

      <!-- Messages Area -->
      <div #scrollContainer class="flex-1 overflow-y-auto p-4 flex flex-col gap-3 scroll-smooth bg-slate-50/50 dark:bg-transparent">
        @if (chatService.messages().length === 0) {
          <div class="flex-1 flex flex-col items-center justify-center text-center px-10">
            <div class="w-16 h-16 rounded-full bg-white dark:bg-slate-800 flex items-center justify-center mb-4 shadow-sm">
               <span class="material-symbols-outlined text-3xl text-slate-300">forum</span>
            </div>
            <h4 class="text-slate-800 dark:text-white font-bold mb-1">¡Hola!</h4>
            <p class="text-slate-400 text-xs leading-relaxed">Soy el asistente de Las Condes. ¿En qué puedo ayudarte hoy?</p>
          </div>
        }

        @for (msg of chatService.messages(); track msg.id) {
          <div class="flex flex-col w-full" [ngClass]="msg.role === 'user' ? 'items-end' : 'items-start'">
            <div class="max-w-[85%] rounded-[20px] px-4 py-3 text-[14.5px] shadow-sm transition-all leading-relaxed"
                 [ngClass]="msg.role === 'user' 
                  ? 'bg-[#0084FF] text-white rounded-tr-[4px]' 
                  : 'bg-white dark:bg-[#2F3337] text-slate-800 dark:text-slate-100 rounded-tl-[4px] border border-slate-100 dark:border-none'"
                 [innerHTML]="formatMessage(msg.content)">
            </div>
            <span class="text-[10px] mt-1 text-slate-400 px-2">{{ msg.timestamp | date:'HH:mm' }}</span>
          </div>
        }

        @if (isLoading()) {
          <div class="flex items-start gap-2 mb-4">
             <div class="bg-white dark:bg-[#2F3337] rounded-full px-4 py-3 flex gap-1 shadow-sm">
                <span class="w-1.5 h-1.5 bg-slate-400 rounded-full animate-bounce"></span>
                <span class="w-1.5 h-1.5 bg-slate-400 rounded-full animate-bounce [animation-delay:0.2s]"></span>
                <span class="w-1.5 h-1.5 bg-slate-400 rounded-full animate-bounce [animation-delay:0.4s]"></span>
             </div>
          </div>
        }
      </div>

      <!-- Input Area -->
      <div class="p-4 bg-white dark:bg-[#1E293B] border-t border-slate-100 dark:border-slate-800">
        <form (ngSubmit)="sendMessage()" class="flex items-center gap-2">
          <div class="flex-1 relative">
            <input 
              #messageInput
              type="text" 
              [(ngModel)]="newMessage" 
              name="message" 
              placeholder="Escribe un mensaje..." 
              class="w-full bg-[#F0F2F5] dark:bg-[#2F3337] border-none rounded-full px-5 py-3 text-[14px] text-slate-800 dark:text-white placeholder:text-slate-400 focus:ring-2 focus:ring-primary/20 outline-none transition-all"
              [disabled]="isLoading()"
              autocomplete="off"
              required>
          </div>
          <button 
            type="submit" 
            [disabled]="isLoading() || !newMessage.trim()"
            class="p-2 text-[#0084FF] disabled:opacity-30 disabled:grayscale transition-all transform active:scale-90 flex items-center justify-center">
            <span class="material-symbols-outlined text-[28px]">send</span>
          </button>
        </form>
      </div>
    </div>
  `
})
export class ChatComponent {
  chatService = inject(ChatService);
  private toast = inject(ToastService);
  private sanitizer = inject(DomSanitizer);

  @ViewChild('scrollContainer') private scrollContainer!: ElementRef;
  @ViewChild('messageInput') private messageInput!: ElementRef;

  newMessage = '';
  isLoading = signal(false);
  isOpen = signal(false);
  hasNewMessages = signal(false);

  constructor() {
    effect(() => {
      const msgs = this.chatService.messages();
      if (msgs.length > 0 && !this.isOpen()) {
        this.hasNewMessages.set(true);
      }
      setTimeout(() => this.scrollToBottom(), 50);
    });
  }

  toggleChat() {
    this.isOpen.update(v => !v);
    if (this.isOpen()) {
      this.hasNewMessages.set(false);
      setTimeout(() => this.messageInput?.nativeElement?.focus(), 100);
    }
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
        setTimeout(() => this.scrollToBottom(), 50);
      },
      error: (err) => {
        this.toast.error('Error al conectar con el asistente');
        this.isLoading.set(false);
      }
    });
  }

  formatMessage(text: string): SafeHtml {
    if (!text) return '';
    
    // Scape HTML to prevent XSS (basic)
    let escaped = text
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#039;");

    // Convert **bold** to <strong>
    let formatted = escaped.replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>');
    
    // Convert line breaks to <br>
    formatted = formatted.replace(/\n/g, '<br>');
    
    // Convert simple bullet points
    formatted = formatted.replace(/^\s*[-*]\s+(.*)$/gm, '• $1');

    return this.sanitizer.bypassSecurityTrustHtml(formatted);
  }

  private scrollToBottom(): void {
    try {
      if (this.scrollContainer) {
        this.scrollContainer.nativeElement.scrollTop = this.scrollContainer.nativeElement.scrollHeight;
      }
    } catch(err) { }
  }
}
