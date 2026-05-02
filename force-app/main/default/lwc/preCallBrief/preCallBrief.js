import { LightningElement, api, wire } from 'lwc'; 
import getBriefData from '@salesforce/apex/PreCallBriefController.getBriefData'; 
import simulateMarketCrash from '@salesforce/apex/PreCallBriefController.simulateMarketCrash';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class PreCallBrief extends LightningElement { 
    @api recordId;  // Individual record Id from page context 
    brief = {}; 
    error; 
    isSimulating = false;

    @wire(getBriefData, { clientId: '$recordId' }) 
    wiredBrief({ error, data }) { 
        if (data) { 
            this.brief = data; 
        } else if (error) { 
            this.error = error; 
        } 
    } 

    handleSimulateCrash() {
        this.isSimulating = true;
        simulateMarketCrash()
            .then(result => {
                if(result.includes('Success')) {
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Market Crash Simulated',
                        message: 'Agentforce is now evaluating client impact in the background.',
                        variant: 'success',
                        mode: 'sticky'
                    }));
                } else {
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Simulation Error',
                        message: result,
                        variant: 'error'
                    }));
                }
            })
            .catch(error => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Simulation Failed',
                    message: error.body ? error.body.message : error.message,
                    variant: 'error'
                }));
            })
            .finally(() => {
                this.isSimulating = false;
            });
    }
} 
