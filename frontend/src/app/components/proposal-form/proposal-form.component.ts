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
    <div class="glass-card p-lg">
      <h4 class="font-heading-md text-heading-md mb-md">Nueva propuesta ciudadana</h4>
      <form (ngSubmit)="onSubmit(proposalForm)" #proposalForm="ngForm" novalidate class="flex flex-col gap-md">
         <div>
           <label class="font-label text-label text-on-surface-variant mb-xs block">Título</label>
           <input 
             class="input-glass"
             type="text" 
             name="title" 
             [(ngModel)]="proposal.title" 
             required 
             minlength="10"
             placeholder="Ej: Nuevo parque en el centro"
           >
           <p class="text-error text-xs mt-1" *ngIf="proposalForm.controls['title']?.touched && proposalForm.controls['title']?.invalid">
             El título debe tener al menos 10 caracteres.
           </p>
         </div>

         <div>
           <label class="font-label text-label text-on-surface-variant mb-xs block">Categoría</label>
           <select 
             class="input-glass"
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
           <p class="text-error text-xs mt-1" *ngIf="proposalForm.controls['category']?.touched && proposalForm.controls['category']?.invalid">
             Selecciona una categoría.
           </p>
         </div>

         <div>
           <label class="font-label text-label text-on-surface-variant mb-xs block">Descripción</label>
           <textarea 
             class="input-glass min-h-28"
             name="description" 
             [(ngModel)]="proposal.description" 
             required 
             minlength="30"
             rows="4"
             placeholder="Describe tu propuesta detalladamente..."
           ></textarea>
           <p class="text-error text-xs mt-1" *ngIf="proposalForm.controls['description']?.touched && proposalForm.controls['description']?.invalid">
             La descripción debe tener al menos 30 caracteres.
           </p>
         </div>

        <button class="btn btn-primary w-full mt-2" type="submit" [disabled]="!isFormValid(proposalForm) || isSubmitting()">
          {{ isSubmitting() ? 'Enviando...' : 'Publicar Propuesta' }}
        </button>

        <p class="text-error text-sm text-center" *ngIf="submitError">{{ submitError }}</p>
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
