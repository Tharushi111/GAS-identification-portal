import { Component } from '@angular/core';

@Component({
  selector: 'app-footer',
  imports: [],
  templateUrl: './footer.html',
  styleUrl: './footer.css'
})
export class Footer {

  onSubscribe(event: Event): void {
    event.preventDefault();

    // Frontend only for now.
    // Connect this to backend later if required.
    console.log('Subscribe clicked');
  }
}