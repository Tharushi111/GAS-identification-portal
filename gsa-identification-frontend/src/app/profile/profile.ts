import { Component } from '@angular/core';
import {
  FormBuilder,
  FormGroup,
  ReactiveFormsModule,
  Validators
} from '@angular/forms';

import { Header } from '../shared/header/header';
import { AccountSidebar } from '../shared/account-sidebar/account-sidebar';
import { Footer } from '../shared/footer/footer';

@Component({
  selector: 'app-profile',
  imports: [
    ReactiveFormsModule,
    Header,
    AccountSidebar,
    Footer
  ],
  templateUrl: './profile.html',
  styleUrl: './profile.css'
})
export class Profile {

  profileForm: FormGroup;

  isEditing = false;

  constructor(private fb: FormBuilder) {

    this.profileForm = this.fb.group({

      firstName: [
        'Kasun',
        Validators.required
      ],

      lastName: [
        'Silva',
        Validators.required
      ],

      email: [
        'kasun.silva@horizontravels.com',
        [
          Validators.required,
          Validators.email
        ]
      ],

      phoneNumber: [
        '+44 7700 900123'
      ],

      password: [
        'password123'
      ],

      confirmPassword: [
        'password123'
      ],

      jobTitle: [
        ''
      ],

      preferredLanguage: [
        ''
      ],

      companyName: [
        ''
      ],

      country: [
        ''
      ],

      city: [
        ''
      ],

      legalOrganizationName: [
        ''
      ],

      applicantType: [
        ''
      ],

      territory: [
        ''
      ],

      iataStatus: [
        ''
      ]

    });

    this.profileForm.disable();
  }


  enableEditing(): void {

    this.isEditing = true;

    this.profileForm.enable();

  }


  saveChanges(): void {

    if (this.profileForm.invalid) {

      this.profileForm.markAllAsTouched();

      return;
    }

    console.log(
      'Profile:',
      this.profileForm.getRawValue()
    );

    this.isEditing = false;

    this.profileForm.disable();
  }


  completeProfile(): void {

    this.enableEditing();

  }


  changePassword(): void {

    console.log(
      'Change password selected'
    );

  }

}