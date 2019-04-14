import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';

@Component({
  selector: 'app-mails',
  templateUrl: './mails.component.html',
  styleUrls: ['./mails.component.css']
})
export class MailsComponent implements OnInit {

  Check(elem) {
    console.log(elem[name]);
    if (elem === 'checked') {
      elem.src = '../../assets/Rectangle 15.png';
      elem.name = 'notChecked';
    } else {
      elem.src = '../../assets/Checked.png';
      elem.name = 'checked';
    }
  }

  CheckAll() {
    const mails = document.getElementsByClassName('mail');
    const control = document.getElementsByClassName('control-elements');
    let i;
    for (i = 0; i < mails.length; i++) {
      if (mails.item(i).children[0].getAttribute('name') === 'checked') {
        mails.item(i).children[0].setAttribute('src', '../../assets/Rectangle 15.png');
        mails.item(i).children[0].setAttribute('name', 'notChecked');
        control.item(0).children[0].setAttribute('src', '../../assets/Rectangle 15.png');
        control.item(0).children[0].setAttribute('name', 'notChecked');
      } else {
        mails.item(i).children[0].setAttribute('src', '../../assets/Checked.png');
        mails.item(i).children[0].setAttribute('name', 'checked');
        control.item(0).children[0].setAttribute('src', '../../assets/Checked.png');
        control.item(0).children[0].setAttribute('name', 'Checked');
      }
    }
  }

  OpenMail(elem) {
    this.router.navigate(['/mail']);
  }
  constructor(private router: Router) { }

  ngOnInit() {
  }

}
