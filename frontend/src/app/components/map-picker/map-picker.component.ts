import { Component, EventEmitter, Input, OnInit, Output, OnDestroy, ElementRef, ViewChild, AfterViewInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import * as L from 'leaflet';

@Component({
  selector: 'app-map-picker',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="map-container relative w-full h-64 rounded-lg overflow-hidden border border-outline-variant shadow-sm z-10">
      <div #mapElement class="w-full h-full"></div>
      <div class="absolute top-2 right-2 bg-surface p-2 rounded-md shadow-md z-[1000] text-sm font-label pointer-events-none">
        Haz clic en el mapa para ubicar la problemática
      </div>
    </div>
  `,
  styles: [`
    .map-container {
      /* Ensure leaflet map displays correctly */
      min-height: 250px;
    }
  `]
})
export class MapPickerComponent implements AfterViewInit, OnDestroy {
  @ViewChild('mapElement') mapElement!: ElementRef;
  
  @Input() initialLat: number | undefined;
  @Input() initialLng: number | undefined;
  
  @Output() locationSelected = new EventEmitter<{lat: number, lng: number}>();

  private map: L.Map | undefined;
  private marker: L.Marker | undefined;

  private readonly customIcon = L.divIcon({
    className: 'custom-map-marker',
    html: `<div style="background-color: #ef4444; width: 24px; height: 24px; border-radius: 50%; border: 3px solid white; box-shadow: 0 2px 5px rgba(0,0,0,0.5); transform: translate(-50%, -100%);"></div>`,
    iconSize: [0, 0], // The HTML itself gives it size
    iconAnchor: [0, 0]
  });

  ngAfterViewInit() {
    this.initMap();
  }

  ngOnDestroy() {
    if (this.map) {
      this.map.remove();
    }
  }

  private initMap() {
    // Default to a central location (e.g., Santiago, Chile or a generic center)
    // We'll use a generic center or the provided initial coordinates
    const centerLat = this.initialLat || -33.4489;
    const centerLng = this.initialLng || -70.6693;
    const zoom = this.initialLat && this.initialLng ? 15 : 10;

    this.map = L.map(this.mapElement.nativeElement).setView([centerLat, centerLng], zoom);

    L.tileLayer('https://{s}.google.com/vt/lyrs=m&x={x}&y={y}&z={z}', {
      maxZoom: 20,
      subdomains: ['mt0', 'mt1', 'mt2', 'mt3'],
      attribution: '© Google'
    }).addTo(this.map);

    if (this.initialLat && this.initialLng) {
      this.marker = L.marker([this.initialLat, this.initialLng], { icon: this.customIcon }).addTo(this.map);
    }

    this.map.on('click', (e: L.LeafletMouseEvent) => {
      const { lat, lng } = e.latlng;
      
      if (this.marker) {
        this.marker.setLatLng([lat, lng]);
      } else {
        this.marker = L.marker([lat, lng], { icon: this.customIcon }).addTo(this.map!);
      }
      
      this.locationSelected.emit({ lat, lng });
    });
    
    // Invalidate size to ensure it renders correctly after being placed in a container
    setTimeout(() => {
      this.map?.invalidateSize();
    }, 100);
  }
}
