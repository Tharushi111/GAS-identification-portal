import { Component } from '@angular/core';
import { RouterLink, RouterLinkActive } from '@angular/router';

@Component({
  selector: 'app-account-sidebar',
  imports: [
    RouterLink,
    RouterLinkActive
  ],
  templateUrl: './account-sidebar.html',
  styleUrl: './account-sidebar.css'
})
export class AccountSidebar {

}