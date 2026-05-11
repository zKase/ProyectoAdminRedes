import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ToastService } from '../../services/toast.service';

@Component({
  selector: 'app-toast',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="fixed bottom-4 right-4 z-50 flex flex-col gap-2">
      @for (toast of toastService.toasts(); track toast.id) {
        <div 
          class="flex items-center gap-3 px-4 py-3 rounded-xl shadow-lg transform transition-all duration-300 translate-y-0 opacity-100 min-w-[300px]"
          [ngClass]="{
            'bg-green-600 text-white': toast.type === 'success',
            'bg-red-600 text-white': toast.type === 'error',
            'bg-blue-600 text-white': toast.type === 'info'
          }"
        >
          <span class="material-symbols-outlined text-[20px]">
            {{ toast.type === 'success' ? 'check_circle' : toast.type === 'error' ? 'error' : 'info' }}
          </span>
          <p class="font-medium text-sm m-0">{{ toast.message }}</p>
          <button (click)="toastService.remove(toast.id)" class="ml-auto hover:opacity-80 transition-opacity">
            <span class="material-symbols-outlined text-[18px]">close</span>
          </button>
        </div>
      }
    </div>
  `
})
export class ToastComponent {
  toastService = inject(ToastService);
}
