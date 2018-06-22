$('[data-toggle="tooltip"]').tooltip();
setTimeout($(".updateable:visible").each(function(){
   return this.src = new URL(this.src).setSearch("timestamp", (new Date).getTime()).toString();
}),5000);
