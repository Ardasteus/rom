import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';

import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { NavComponent } from './nav/nav.component';
import { LoginComponent } from './login/login.component';
import { InboxComponent } from './inbox/inbox.component';
import { MailComponent } from './mail/mail.component';
import { ChatComponent } from './chat/chat.component';
import { NewComponent } from './new/new.component';
import { FolderComponent } from './folder/folder.component';
import { SentComponent } from './sent/sent.component';
import { SpamComponent } from './spam/spam.component';
import { MailsComponent } from './mails/mails.component';

@NgModule({
  declarations: [
    AppComponent,
    NavComponent,
    LoginComponent,
    InboxComponent,
    MailComponent,
    ChatComponent,
    NewComponent,
    FolderComponent,
    SentComponent,
    SpamComponent,
    MailsComponent
  ],
  imports: [
    BrowserModule,
    AppRoutingModule
  ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule { }
