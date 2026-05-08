import { Component, EventEmitter, Output, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ProposalService } from '../../services/proposal.service';
import { CreateProposalDto } from '../../models/proposal.model';

@Component({
  selector: 'app-proposal-form',
  standalone: true,
  imports: [CommonModule, FormsModule],
  template: `
    <div class="form-container">
      <form (ngSubmit)="onSubmit(proposalForm)" #proposalForm="ngForm" novalidate>
        <div class="form-group">
          <label for="title">Título</label>
          <input 
            type="text" 
            id="title" 
            name="title" 
            [(ngModel)]="proposal.title" 
            required 
            minlength="10"
            placeholder="Ej: Nuevo parque en el centro"
            aria-label="Título de la propuesta"
          >
          <div class="field-error" *ngIf="titleInvalid(proposalForm)">
            El título es obligatorio y debe tener al menos 10 caracteres.
          </div>
        </div>

        <div class="form-group">
          <label for="category">Categoría</label>
          <select 
            id="category" 
            name="category" 
            [(ngModel)]="proposal.category" 
            required
            aria-label="Categoría de la propuesta"
          >
            <option value="" disabled>Selecciona una categoría</option>
            <option value="Infraestructura">Infraestructura</option>
            <option value="Medio Ambiente">Medio Ambiente</option>
            <option value="Seguridad">Seguridad</option>
            <option value="Cultura">Cultura</option>
            <option value="Otro">Otro</option>
          </select>
          <div class="field-error" *ngIf="categoryInvalid(proposalForm)">
            Selecciona una categoría.
          </div>
        </div>

        <div class="form-group">
          <label for="description">Descripción</label>
          <textarea 
            id="description" 
            name="description" 
            [(ngModel)]="proposal.description" 
            required 
            minlength="30"
            rows="4"
            placeholder="Describe tu propuesta detalladamente..."
            aria-label="Descripción de la propuesta"
          ></textarea>
          <div class="field-error" *ngIf="descriptionInvalid(proposalForm)">
            La descripción es obligatoria y debe contener al menos 30 caracteres.
          </div>
        </div>

        <div class="form-actions">
          <button type="submit" [disabled]="!isFormValid(proposalForm) || isSubmitting">
            {{ isSubmitting ? 'Enviando...' : 'Publicar Propuesta' }}
          </button>
        </div>

        <div class="submit-error" *ngIf="submitError">{{ submitError }}</div>
      </form>
    </div>
  `,
  styles: [`
    .form-container {
      background: #ffffff;
      padding: 1.5rem;
      border-radius: 18px;
      box-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1);
      border: 1px solid #e2e8f0;
    }

    .form-group {
      margin-bottom: 1.25rem;
    }

    label {
      display: block;
      font-size: 0.875rem;
      font-weight: 500;
      margin-bottom: 0.5rem;
      color: #434654;
      letter-spacing: 0.01em;
    }

    input, select, textarea {
      width: 100%;
      padding: 0.75rem;
      border: 1px solid #c3c6d6;
      border-radius: 8px;
      font-family: Inter, sans-serif;
      font-size: 1rem;
      transition: border-color 0.2s, box-shadow 0.2s;
      background-color: #ffffff;
      color: #0d1c2f;
    }

    input:focus, select:focus, textarea:focus {
      outline: none;
      border-color: #004ac6;
      box-shadow: 0 0 0 3px rgba(0, 74, 198, 0.25);
      background-color: #ffffff;
    }

    textarea {
      resize: vertical;
      min-height: 4rem;
    }

    button {
      width: 100%;
      background: #004ac6;
      color: white;
      border: none;
      padding: 0.875rem;
      border-radius: 18px;
      font-family: Inter, sans-serif;
      font-weight: 500;
      font-size: 0.875rem;
      cursor: pointer;
      transition: background-color 0.2s, transform 0.1s;
      letter-spacing: 0.01em;
      text-transform: none;
    }

    button:hover:not(:disabled) {
      background: #003594;
    }

    button:active:not(:disabled) {
      transform: scale(0.98);
    }

    button:disabled {
      background: #b4c5ff;
      cursor: not-allowed;
      opacity: 0.7;
    }

    .field-error {
      display: block;
      margin-top: 0.5rem;
      font-size: 0.75rem;
      font-weight: 400;
      color: #ba1a1a;
    }
  `]
})
export class ProposalFormComponent {
  @Output() proposalCreated = new EventEmitter<void>();
  private proposalService = inject(ProposalService);

  proposal: CreateProposalDto = {
    title: '',
    description: '',
    category: ''
  };
  isSubmitting = false;
  submitError?: string;

  // Submission handler with form passed in
  onSubmit(form: any) {
    if (!this.isFormValid(form)) return;
    this.isSubmitting = true;
    this.submitError = undefined;
    this.proposalService.createProposal(this.proposal).subscribe({
      next: () => {
        this.proposalCreated.emit();
        this.proposal = { title: '', description: '', category: '' }; // Reset form
        form.resetForm();
        this.isSubmitting = false;
      },
      error: (err) => {
        console.error('Error al crear propuesta', err);
        this.submitError = 'No se pudo crear la propuesta. Intenta de nuevo.';
        this.isSubmitting = false;
      }
    });
  }

  isFormValid(form: any): boolean {
    if (!form) return false;
    return form.form && form.form.valid;
  }

  titleInvalid(form: any): boolean {
    return !!form && form.submitted && form.form.controls?.title?.invalid;
  }

  categoryInvalid(form: any): boolean {
    return !!form && form.submitted && form.form.controls?.category?.invalid;
  }

  descriptionInvalid(form: any): boolean {
    return !!form && form.submitted && form.form.controls?.description?.invalid;
  }
}
