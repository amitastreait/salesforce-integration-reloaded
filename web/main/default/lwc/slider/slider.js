import { LightningElement } from 'lwc';

export default class SliderComponent extends LightningElement {
    currentIndex = 0;
    slideInterval;

    renderedCallback() {
        this.showSlide(this.currentIndex);
        this.startAutoSlide();
    }

    startAutoSlide() {
        this.slideInterval = setInterval(() => {
            this.nextSlide();
        }, 3000); // Change slide every 3 seconds
    }

    stopAutoSlide() {
        clearInterval(this.slideInterval);
    }

    showSlide(index) {
        const slides = this.template.querySelectorAll('.slide');
        slides.forEach(slide => slide.classList.remove('active'));
        slides[index].classList.add('active');
    }

    prevSlide() {
        this.stopAutoSlide();
        this.currentIndex = (this.currentIndex > 0) ? this.currentIndex - 1 : this.template.querySelectorAll('.slide').length - 1;
        this.showSlide(this.currentIndex);
        this.startAutoSlide();
    }

    nextSlide() {
        this.stopAutoSlide();
        this.currentIndex = (this.currentIndex < this.template.querySelectorAll('.slide').length - 1) ? this.currentIndex + 1 : 0;
        this.showSlide(this.currentIndex);
        this.startAutoSlide();
    }
}