import { ComponentFixture, TestBed } from '@angular/core/testing';

import { PresentarExamenComponent } from './presentar-examen.component';

describe('PresentarExamenComponent', () => {
  let component: PresentarExamenComponent;
  let fixture: ComponentFixture<PresentarExamenComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [PresentarExamenComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(PresentarExamenComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
