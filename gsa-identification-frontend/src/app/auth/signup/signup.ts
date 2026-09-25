import { Component } from '@angular/core';
import {
  AbstractControl,
  FormBuilder,
  FormGroup,
  ReactiveFormsModule,
  ValidationErrors,
  Validators
} from '@angular/forms';
import { RouterLink } from '@angular/router';

@Component({
  selector: 'app-signup',
  imports: [
    ReactiveFormsModule,
    RouterLink
  ],
  templateUrl: './signup.html',
  styleUrl: './signup.css'
})
export class Signup {

  signupForm: FormGroup;

  showPassword = false;
  showConfirmPassword = false;

  constructor(private fb: FormBuilder) {

    this.signupForm = this.fb.group(
      {
        firstName: [
          '',
          [
            Validators.required,
            Validators.maxLength(100)
          ]
        ],

        lastName: [
          '',
          [
            Validators.required,
            Validators.maxLength(100)
          ]
        ],

        email: [
          '',
          [
            Validators.required,
            Validators.email
          ]
        ],

        phoneNumber: [
          '',
          [
            Validators.required
          ]
        ],

        password: [
          '',
          [
            Validators.required,
            Validators.minLength(8)
          ]
        ],

        confirmPassword: [
          '',
          [
            Validators.required
          ]
        ],

        acceptTerms: [
          false,
          [
            Validators.requiredTrue
          ]
        ]
      },
      {
        validators: this.passwordMatchValidator
      }
    );
  }


  passwordMatchValidator(
    control: AbstractControl
  ): ValidationErrors | null {

    const password =
      control.get('password')?.value;

    const confirmPassword =
      control.get('confirmPassword')?.value;

    if (!password || !confirmPassword) {
      return null;
    }

    return password === confirmPassword
      ? null
      : { passwordMismatch: true };
  }


  togglePassword(): void {
    this.showPassword = !this.showPassword;
  }


  toggleConfirmPassword(): void {
    this.showConfirmPassword =
      !this.showConfirmPassword;
  }


  onSubmit(): void {

    if (this.signupForm.invalid) {
      this.signupForm.markAllAsTouched();
      return;
    }

    console.log(
      'Signup form:',
      this.signupForm.value
    );

    // Backend registration API will be connected later.
  }
}