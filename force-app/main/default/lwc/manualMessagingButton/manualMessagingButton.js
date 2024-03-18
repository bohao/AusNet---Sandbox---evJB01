import { LightningElement, api, wire, track } from 'lwc';
import  mmModal  from 'c/manualMessagingModal';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class manualMessagingButton extends NavigationMixin(LightningElement){
	 @api recordId;
	 async handleClick() {
		const result = await mmModal.open({
			options: [
		{ id: 'objectApiName', label: 'Campaign' },
		{ id: 'recordId', label: this.recordId},
	  ],
			// `label` is not included here in this example.
			// it is set on lightning-modal-header instead
			size: 'small',
			description: 'Manual Messaging',
			content: 'Campaign',
		});
		// if modal closed with X button, promise returns result = 'undefined'
		// if modal closed with OK button, promise returns result = 'okay'
		console.log('result'+result);
		if(result==='Success'){
			this.dispatchEvent(
				new ShowToastEvent({
					title: 'Success',
					message: 'Messaging Record Created!',
					variant: 'success'
					})
				);
		}

	}

	loadImportWiz(){
		this[NavigationMixin.GenerateUrl]({
			type: 'standard__webPage',
			attributes: {
				url: '/dataImporter/dataimporter.app?objectSelection=Segment_Loader__c,Tariff_Trial__c'
			}
		}).then(generatedUrl => {
			window.open(generatedUrl);
		});
	}

	loadHowTo(){
		window.open('https://www.outagetracker.com.au/faqs');
	}


}