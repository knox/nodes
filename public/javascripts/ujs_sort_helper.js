Event.addBehavior({ 
  'a.sort_link:click': function(e) { 
		new Ajax.Request(this.href, {asynchronous:true, evalScripts:true, method:'get'}); 
		return false;
  },
  'div.pagination a:click': function(e) { 
		new Ajax.Request(this.href, {asynchronous:true, evalScripts:true, method:'get'}); 
		return false;
  }
});

Event.addBehavior.reassignAfterAjax = true;

