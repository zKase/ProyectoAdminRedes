import { Component, EventEmitter, Output, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ProposalService } from '../../services/proposal.service';
import { CreateProposalDto } from '../../models/proposal.model';

@Component({
  selector: 'app-proposal-form',
  standalone: true,
  imports: [CommonModule, FormsModule],
  template: `
    <div class="glass-card p-8 bg-surface border border-outline-variant/30 shadow-lg">
      <h4 class="text-xl font-bold text-on-surface mb-6">Nueva propuesta ciudadana</h4>
      <form (ngSubmit)="onSubmit(proposalForm)" #proposalForm="ngForm" novalidate class="flex flex-col gap-5">
         <div>
           <label class="text-xs font-bold text-on-surface tracking-wide mb-2 block">Título de la Propuesta</label>
           <input 
             class="w-full px-4 py-3 rounded-lg border border-outline-variant/50 focus:border-primary focus:ring-1 focus:ring-primary/10 bg-surface-container-low text-sm text-on-surface outline-none transition-all"
             type="text" 
             name="title" 
             [(ngModel)]="proposal.title" 
             required 
             minlength="10"
             placeholder="Ej: Nuevo parque sustentable..."
           >
           <p class="text-error text-[10px] font-bold mt-1" *ngIf="proposalForm.controls['title']?.touched && proposalForm.controls['title']?.invalid">
             El título debe tener al menos 10 caracteres.
           </p>
         </div>

         <div>
           <label class="text-xs font-bold text-on-surface tracking-wide mb-2 block">Categoría</label>
           <select 
             class="w-full px-4 py-3 rounded-lg border border-outline-variant/50 focus:border-primary focus:ring-1 focus:ring-primary/10 bg-surface-container-low text-sm text-on-surface outline-none transition-all appearance-none"
             name="category" 
             [(ngModel)]="proposal.category" 
             required
           >
             <option value="" disabled>Selecciona una categoría</option>
             <option value="Infraestructura">Infraestructura</option>
             <option value="Medio Ambiente">Medio Ambiente</option>
             <option value="Seguridad">Seguridad</option>
             <option value="Cultura">Cultura</option>
             <option value="Otro">Otro</option>
           </select>
         </div>

         <div>
           <label class="text-xs font-bold text-on-surface tracking-wide mb-2 block">Descripción Detallada</label>
           <textarea 
             class="w-full px-4 py-3 rounded-lg border border-outline-variant/50 focus:border-primary focus:ring-1 focus:ring-primary/10 bg-surface-container-low text-sm text-on-surface outline-none transition-all min-h-32"
             name="description" 
             [(ngModel)]="proposal.description" 
             required 
             minlength="30"
             rows="4"
             placeholder="Describe tu propuesta..."
           ></textarea>
           <p class="text-error text-[10px] font-bold mt-1" *ngIf="proposalForm.controls['description']?.touched && proposalForm.controls['description']?.invalid">
             La descripción debe tener al menos 30 caracteres.
           </p>
         </div>

        <button class="w-full bg-primary text-on-primary font-bold text-sm py-3.5 rounded-lg flex items-center justify-center gap-2 hover:bg-primary-hover transition-all duration-200 shadow-md disabled:opacity-50 disabled:cursor-not-allowed active:scale-[0.98]" type="submit" [disabled]="!isFormValid(proposalForm) || isSubmitting()">
          <span class="material-symbols-outlined text-[18px]">send</span>
          <span>{{ isSubmitting() ? 'Publicando...' : 'Publicar Propuesta' }}</span>
        </button>

        <p class="text-error text-xs font-bold text-center" *ngIf="submitError">{{ submitError }}</p>
      </form>
    </div>
  `,
  styles: []
})
export class ProposalFormComponent {
  @Output() proposalCreated = new EventEmitter<void>();
  private proposalService = inject(ProposalService);

  proposal: CreateProposalDto = {
    title: '',
    description: '',
    category: ''
  };
  isSubmitting = signal(false);
  submitError?: string;

  onSubmit(form: any) {
    if (!this.isFormValid(form)) return;
    this.isSubmitting.set(true);
    this.submitError = undefined;
    this.proposalService.createProposal(this.proposal).subscribe({
      next: () => {
        this.proposalCreated.emit();
        this.proposal = { title: '', description: '', category: '' };
        form.resetForm();
        this.isSubmitting.set(false);
      },
      error: (err) => {
        console.error('Error al crear propuesta', err);
        this.submitError = 'No se pudo crear la propuesta. Intenta de nuevo.';
        this.isSubmitting.set(false);
      }
    });
  }

  isFormValid(form: any): boolean {
    if (!form) return false;
    return form.form && 
      form.form.controls?.['title']?.valid && 
      form.form.controls?.['category']?.valid && 
      form.form.controls?.['description']?.valid;
  }
}
