/* eslint-disable @lwc/lwc/no-api-reassignments */
/* eslint-disable @lwc/lwc/no-leading-uppercase-api-name */
/* eslint-disable no-unused-vars */
/* eslint-disable no-console */
import { LightningElement, api } from 'lwc';
import saveSign from '@salesforce/apex/SignatureLwcHelper.saveSignature';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LightningAlert from 'lightning/alert';
let isDownFlag,
    isDotFlag = false,
    prevX = 0,
    currX = 0,
    prevY = 0,
    currY = 0;

let x = "#0000A0"; // blue color
let y = 1.5; // weight of line width and dot.

let canvasElement, ctx; // storing canvas context
let dataURL, convertedDataURI; // holds image data

export default class CaptureSignature extends LightningElement {
    @api recordId = '001Hu00003C4CjiIAF';
    @api ContentVersionData;
    @api contentVersionId;

    isSpinner = false;
    isCanvas;

    constructor() {
        super();
        this.handleMouseMove = this.handleMouseMove.bind(this);
        this.handleMouseDown = this.handleMouseDown.bind(this);
        this.handleMouseUp = this.handleMouseUp.bind(this);
        this.handleMouseOut = this.handleMouseOut.bind(this);
        this.handleTouchMove = this.handleTouchMove.bind(this);
        this.handleTouchStart = this.handleTouchStart.bind(this);
        this.handleTouchEnd = this.handleTouchEnd.bind(this);
    }

    renderedCallback() {
        canvasElement = this.template.querySelector('canvas');
        ctx = canvasElement.getContext("2d");

        // Add event listeners for both mouse and touch events
        canvasElement.addEventListener('mousemove', this.handleMouseMove);
        canvasElement.addEventListener('mousedown', this.handleMouseDown);
        canvasElement.addEventListener('mouseup', this.handleMouseUp);
        canvasElement.addEventListener('mouseout', this.handleMouseOut);

        canvasElement.addEventListener('touchmove', this.handleTouchMove);
        canvasElement.addEventListener('touchstart', this.handleTouchStart);
        canvasElement.addEventListener('touchend', this.handleTouchEnd);
    }

    handleMouseMove(event) {
        this.searchCoordinatesForEvent('move', event);
    }

    handleMouseDown(event) {
        this.searchCoordinatesForEvent('down', event);
    }

    handleMouseUp(event) {
        this.searchCoordinatesForEvent('up', event);
    }

    handleMouseOut(event) {
        this.searchCoordinatesForEvent('out', event);
    }

    handleTouchMove(event) {
        if (event && event.preventDefault) {
            event.preventDefault();
        }
        this.searchCoordinatesForEvent('move', event.touches[0]);
    }

    handleTouchStart(event) {
        if (event && event.preventDefault) {
            event.preventDefault();
        }
        this.searchCoordinatesForEvent('down', event.touches[0]);
    }

    handleTouchEnd(event) {
        if (event && event.preventDefault) {
            event.preventDefault();
        }
        this.searchCoordinatesForEvent('up', event.touches[0]);
    }

    handleSaveClick() {

        // Check if there is content in the signature
        if (!ctx.getImageData(0, 0, canvasElement.width, canvasElement.height).data.some(channel => channel !== 0)) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please provide a signature before saving.',
                    variant: 'error',
                }),
            );
            return;
        }

        //set to draw behind current content
        ctx.globalCompositeOperation = "destination-over";
        ctx.fillStyle = "#FFF"; //white
        ctx.fillRect(0, 0, canvasElement.width, canvasElement.height);

        //convert to png image as dataURL
        dataURL = canvasElement.toDataURL("image/png");
        //convert that as base64 encoding
        convertedDataURI = dataURL.replace(/^data:image\/(png|jpg);base64,/, "");
        this.ContentVersionData = convertedDataURI;
        //call Apex method imperatively and use promise for handling sucess & failure
        
        this.isSpinner = true;
        saveSign({
                ContentVersionData: convertedDataURI,
                recordId: this.recordId
            })
            .then(result => {
                this.contentVersionId = result;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Salesforce File created with Signature',
                        variant: 'success',
                    }),
                );
            })
            .catch(error => {
                console.log('error : ', error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating Salesforce File record',
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
            })
            .finally(() => {
                this.isSpinner = false;
            });
    }

    //clear the signature from canvas
    handleClearClick() {
        ctx.clearRect(0, 0, canvasElement.width, canvasElement.height);
    }

    searchCoordinatesForEvent(requestedEvent, event) {
        if (event && event.preventDefault) {
            event.preventDefault();
        }
        if (requestedEvent === 'down') {
            this.setupCoordinate(event);
            isDownFlag = true;
            isDotFlag = true;
            if (isDotFlag) {
                this.drawDot();
                isDotFlag = false;
            }
        }
        if (requestedEvent === 'up' || requestedEvent === "out") {
            isDownFlag = false;
        }
        if (requestedEvent === 'move') {
            if (isDownFlag) {
                this.setupCoordinate(event);
                this.redraw();
            }
        }
    }

    setupCoordinate(eventParam) {
        const clientRect = canvasElement.getBoundingClientRect();
        prevX = currX;
        prevY = currY;
        currX = eventParam.clientX - clientRect.left;
        currY = eventParam.clientY - clientRect.top;
    }

    redraw() {
        ctx.beginPath();
        ctx.moveTo(prevX, prevY);
        ctx.lineTo(currX, currY);
        ctx.strokeStyle = x; //sets the color, gradient and pattern of stroke
        ctx.lineWidth = y;
        ctx.closePath(); //create a path from current point to starting point
        ctx.stroke(); //draws the path
    }

    //this draws the dot
    drawDot() {
        ctx.beginPath();
        ctx.fillStyle = x; //blue color
        ctx.fillRect(currX, currY, y, y); //fill rectrangle with coordinates
        ctx.closePath();
    }

    isCanvasEmpty() {
        const pixelBuffer = new Uint32Array(ctx.getImageData(0, 0, canvasElement.width, canvasElement.height).data.buffer);
        console.log('1');
        this.isCanvas = !pixelBuffer.some(pixel => pixel !== 0);
        console.log('2');
    }
}