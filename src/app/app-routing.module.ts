import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';
import { InboxComponent } from './inbox/inbox.component';
import { LoginComponent} from './login/login.component';
import { SentComponent } from './sent/sent.component';
import { SpamComponent } from './spam/spam.component';

const routes: Routes = [
  { path: 'inbox', component: InboxComponent},
  { path: '', component: LoginComponent},
  { path: 'sent', component: SentComponent},
  { path: 'spam', component: SpamComponent},
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
