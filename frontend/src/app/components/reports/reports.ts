import { Component, OnInit, viewChild, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReportsService } from '../../services/reports.service';
import { BaseChartDirective } from 'ng2-charts';
import { ChartConfiguration, ChartData, ChartType } from 'chart.js';

@Component({
  selector: 'app-reports',
  standalone: true,
  imports: [CommonModule, BaseChartDirective],
  templateUrl: './reports.html',
  styleUrl: './reports.css'
})
export class ReportsComponent implements OnInit {
  summary: any = null;
  loading = true;

  // Pie Chart: Issue Statuses
  public pieChartOptions: ChartConfiguration['options'] = {
    responsive: true,
    plugins: {
      legend: {
        display: true,
        position: 'top',
      },
    }
  };
  public pieChartData: ChartData<'pie', number[], string | string[]> = {
    labels: [],
    datasets: [{ data: [] }]
  };
  public pieChartType: ChartType = 'pie';

  // Bar Chart: Totals
  public barChartOptions: ChartConfiguration['options'] = {
    responsive: true,
  };
  public barChartData: ChartData<'bar'> = {
    labels: ['Propuestas', 'Encuestas', 'Presupuestos', 'Incidentes'],
    datasets: [
      { data: [], label: 'Totales' }
    ]
  };
  public barChartType: ChartType = 'bar';

  constructor(
    private reportsService: ReportsService,
    private cd: ChangeDetectorRef
  ) {}

  ngOnInit(): void {
    console.log('ReportsComponent: ngOnInit triggered');
    // Pequeño retraso para asegurar que el componente esté listo
    setTimeout(() => {
      this.loadData();
    }, 100);
  }

  loadData() {
    console.log('ReportsComponent: Fetching summary data...');
    this.loading = true;
    this.reportsService.getSummary().subscribe({
      next: (data) => {
        console.log('ReportsComponent: Data received successfully', data);
        this.summary = data;
        this.updateCharts();
        this.loading = false;
        this.cd.detectChanges(); // Forzar actualización de la vista
      },
      error: (err) => {
        console.error('ReportsComponent: Error loading summary', err);
        this.loading = false;
        this.cd.detectChanges();
      }
    });
  }

  updateCharts() {
    if (!this.summary) return;

    // Update Totals Chart (Immutable update)
    this.barChartData = {
      ...this.barChartData,
      datasets: [
        {
          ...this.barChartData.datasets[0],
          data: [
            this.summary.totals.proposals,
            this.summary.totals.surveys,
            this.summary.totals.budgets,
            this.summary.totals.issues
          ]
        }
      ]
    };

    // Update Issue Statuses Chart (Immutable update)
    const issueStatuses = this.summary.statuses.issues;
    this.pieChartData = {
      labels: issueStatuses.map((s: any) => s.status),
      datasets: [
        {
          ...this.pieChartData.datasets[0],
          data: issueStatuses.map((s: any) => Number(s.count))
        }
      ]
    };
  }

  downloadCsv(type: string) {
    this.reportsService.exportCsv(type).subscribe(blob => {
      const url = window.URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = `reporte-${type}-${new Date().getTime()}.csv`;
      document.body.appendChild(a);
      a.click();
      window.URL.revokeObjectURL(url);
      a.remove();
    });
  }
}
