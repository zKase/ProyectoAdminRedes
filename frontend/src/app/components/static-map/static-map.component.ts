import { Component, Input, ElementRef, ViewChild, AfterViewInit, OnDestroy } from '@angular/core';
import { CommonModule } from '@angular/common';
import * as L from 'leaflet';

@Component({
  selector: 'app-static-map',
  standalone: true,
  imports: [CommonModule],
  template: `<div #mapElement class="w-full h-32 rounded-lg my-sm border border-outline-variant z-10 relative"></div>`
})
export class StaticMapComponent implements AfterViewInit, OnDestroy {
  @ViewChild('mapElement') mapElement!: ElementRef;
  @Input() lat!: number;
  @Input() lng!: number;
  
  private map: L.Map | undefined;

  ngAfterViewInit() {
    if (this.lat === undefined || this.lng === undefined) return;

    this.map = L.map(this.mapElement.nativeElement, {
      zoomControl: false,
      dragging: false,
      scrollWheelZoom: false,
      doubleClickZoom: false,
      boxZoom: false,
      keyboard: false,
      touchZoom: false,
      attributionControl: false // Hide attribution to keep it clean like an image
    }).setView([this.lat, this.lng], 15);

    L.tileLayer('https://{s}.google.com/vt/lyrs=m&x={x}&y={y}&z={z}', {
      maxZoom: 20,
      subdomains: ['mt0', 'mt1', 'mt2', 'mt3']
    }).addTo(this.map);

    const customIcon = L.divIcon({
      className: 'custom-map-marker',
      html: `<div style="background-color: #ef4444; width: 16px; height: 16px; border-radius: 50%; border: 2px solid white; box-shadow: 0 1px 3px rgba(0,0,0,0.5); transform: translate(-50%, -50%);"></div>`,
      iconSize: [0, 0],
      iconAnchor: [0, 0]
    });

    L.marker([this.lat, this.lng], { icon: customIcon }).addTo(this.map);
    
    // Ensure map renders correctly
    setTimeout(() => this.map?.invalidateSize(), 100);
  }

  ngOnDestroy() {
    if (this.map) {
      this.map.remove();
    }
  }
}
