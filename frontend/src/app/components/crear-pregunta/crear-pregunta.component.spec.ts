import { ComponentFixture, TestBed } from '@angular/core/testing';

import { CrearPreguntaComponent } from './crear-pregunta.component';

describe('CrearPreguntaComponent', () => {
  let component: CrearPreguntaComponent;
  let fixture: ComponentFixture<CrearPreguntaComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [CrearPreguntaComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(CrearPreguntaComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
