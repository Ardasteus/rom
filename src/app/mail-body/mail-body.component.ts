import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';

@Component({
  selector: 'app-mail-body',
  templateUrl: './mail-body.component.html',
  styleUrls: ['./mail-body.component.css']
})
export class MailBodyComponent implements OnInit {

  Back() {
    this.router.navigate(['/inbox']);
  }

  constructor(private router: Router) { }

  ngOnInit() {
  }

}
