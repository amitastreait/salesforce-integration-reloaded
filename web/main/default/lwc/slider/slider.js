import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
export default class SliderComponent extends NavigationMixin(LightningElement) {
    currentIndex = 0;
    slideInterval;

    @api slides;

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

    handleClick(event){
        event.preventDefault();
        let url = event.currentTarget.dataset.targetUrl;
        this[NavigationMixin.Navigate]({
            type: "standard__webPage",
            attributes: {
               url: url
            }
        });
    }
}