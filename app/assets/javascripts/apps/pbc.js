//= require can.jquery-all
//= require pbc/responses_controller
//= require pbc/system

(function(namespace, $) {
    
$.widget(
    "pbc.autocomplete"
    , $.ui.autocomplete
    , {
        options : {
            minLength: 1
            , source: CMS.Models.System.search
            , focus: function( event, ui ) {
                //$( "#project" ).val( ui.item.label );
                return false;
            }
            , select: function( event, ui ) {
                var resp = new CMS.Models.Response();
                resp.attr({
                    program_id : $(event.target).closest(".pbc-request").data("filter-id")
                    , system_id : event.target.data("item.autocomplete").id }
                    );
                resp.save();
                return false;
            }
            , open: function() {
                $( this ).removeClass( "ui-corner-all" ).addClass( "ui-corner-top" );
            }
            , close: function() {
                $( this ).removeClass( "ui-corner-top" ).addClass( "ui-corner-all" );
            }
        }
        , _renderItem : function( ul, item ) {
            return $( "<li class='something'>" )
                .data( "item.autocomplete", item )
                .append( "<a>" + item.label + "</a>" )
                .appendTo( ul );
        }
        , _create : function() {
            if(!this.options.source) {
                this.options.source = this.__proto__.source;
            }
            $.ui.autocomplete.prototype._create.apply(this, arguments);
        }
    }
);
$.widget.bridge("pbc_autocomplete", $.pbc.autocomplete);

$(function() {
    $(document.body).on("click", ".pbc-responses-container", function(ev) {
        $(ev.currentTarget).find(".pbc-responses").cms_controllers_responses({id : $(ev.currentTarget).closest("[data-filter-id]").data("filter-id")});
    });

    $("#pbc-system-search").pbc_autocomplete();
});

})(this, can.$);