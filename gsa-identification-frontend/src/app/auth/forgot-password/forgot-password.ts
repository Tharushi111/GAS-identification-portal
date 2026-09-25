import { Component } from '@angular/core';
import {
  FormBuilder,
  FormGroup,
  ReactiveFormsModule,
  Validators
} from '@angular/forms';
import { RouterLink } from '@angular/router';

@Component({
  selector: 'app-forgot-password',
  imports: [
    ReactiveFormsModule,
    RouterLink
  ],
  templateUrl: './forgot-password.html',
  styleUrl: './forgot-password.css'
})
export class ForgotPassword {

  forgotPasswordForm: FormGroup;

  submitted = false;

  constructor(private fb: FormBuilder) {

    this.forgotPasswordForm = this.fb.group({
      email: [
        '',
        [
          Validators.required,
          Validators.email
        ]
      ]
    });

  }

  onSubmit(): void {

    if (this.forgotPasswordForm.invalid) {
      this.forgotPasswordForm.markAllAsTouched();
      return;
    }

    console.log(
      'Password reset requested for:',
      this.forgotPasswordForm.value.email
    );

    /*
      Temporary frontend behaviour.

      Later:
      Angular
        ↓
      POST /api/auth/forgot-password
        ↓
      ASP.NET Core
        ↓
      PasswordResetTokens
        ↓
      Email reset link
    */

    this.submitted = true;
  }
}