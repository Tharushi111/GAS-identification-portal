import { Component } from '@angular/core';

import { Header } from '../shared/header/header';
import { AccountSidebar } from '../shared/account-sidebar/account-sidebar';
import { Footer } from '../shared/footer/footer';

@Component({
  selector: 'app-applications',
  imports: [
    Header,
    AccountSidebar,
    Footer
  ],
  templateUrl: './applications.html',
  styleUrl: './applications.css'
})
export class Applications {

  application = {
    applicationId: 'GSA-2026-000184',
    applicationType: 'Passenger',
    territory: 'United Kingdom',
    submittedDate: '09/08/2026',
    status: 'Submitted'
  };

  viewApplication(): void {
    console.log(
      'View application:',
      this.application.applicationId
    );

    // Later we will navigate to the Application Details page.
  }
}