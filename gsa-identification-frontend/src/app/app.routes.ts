import { Routes } from '@angular/router';
import { Login } from './auth/login/login';
import { Signup } from './auth/signup/signup';
import { ForgotPassword } from './auth/forgot-password/forgot-password';
import { Dashboard } from './dashboard/dashboard';
import { Profile } from './profile/profile';

export const routes: Routes = [
  {
    path: '',
    redirectTo: 'login',
    pathMatch: 'full'
  },
  {
    path: 'login',
    component: Login
  },
  {
    path: 'signup',
    component: Signup
  },
  {
    path: 'forgot-password',
    component: ForgotPassword
  },
  {
    path: 'dashboard',
    component: Dashboard
  },
  {
    path: 'profile',
    component: Profile
  },
  {
    path: '**',
    redirectTo: 'login'
  }
];