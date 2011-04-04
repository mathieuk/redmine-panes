jQuery.noConflict();
(function($){
	
	function move_story_to_pane(story, pane)
	{
		story.parentNode.removeChild(story);
			    
		var li = $('<li />');
		li.append(story);
		$(pane).find('ol').append(li);
		$(story).attr("draggable", "true");
	}
	
	$(document).ready(
		function() 
		{ 
			jQuery.event.props.push('dataTransfer');
			
			$('.story-wrapper').attr("draggable", "true");

			$('.story-wrapper').bind(
				"dragstart", 
				function(e) 
				{ 
					e.dataTransfer.effectAllowed = 'move'; // only dropEffect='copy' will be dropable
					e.dataTransfer.setData('Text', this.id); // required otherwise doesn't work });
				}
			);
			
			$('.story-wrapper').dblclick(function()
			{
				var dialog_container = $('#dialog-container').load(
					'/kanban/edit_issue?issue_id=' + $(this).data('issueid') + ' #edit-issue-form'
				);
				
				dialog_container.dialog({
					modal: true,
					title: 'Update issue',
					position: 'center'
				});
			});
			
			$('.pane').bind("dragover", 
				function(e) { 
					e.preventDefault();
					$(this).addClass("over");
					e.dataTransfer.dropEffect = 'move';
				    return false;
				}
			);

			$('.pane').bind("dragleave", function (e) { $(this).removeClass("over"); });

			$('.pane').bind("drop",
				function (e) 
				{
					e.preventDefault();
					if (e.stopPropagation) e.stopPropagation(); // stops the browser from redirecting...why???
					
					$(this).removeClass("over");
					
					var dropped_story = document.getElementById(e.dataTransfer.getData('Text'));
					src_pane = $(dropped_story).parents('.pane')[0];
					tgt_pane = $(this);
					

					move_story_to_pane(dropped_story, tgt_pane);
									
					issue_id  = $(dropped_story).data('issueid');
					status_id = $(this).data("statusid");
					
					postdata = {
						issue_id: issue_id,
						status_id: status_id
					};
					
					postdata[RB.constants.request_forgery_protection_token] = RB.constants.form_authenticity_token;

					$.ajax({
						type: 'POST',
						url: 	'/kanban/update_pane?' + RB.constants.request_forgery_protection_token + "=" + encodeURIComponent(RB.constants.form_authenticity_token),
						data: postdata,
						success: 	function(data, textStatus, jqXHR) 
						{
							if (typeof data.success != 'undefined')
							{
								if (!data.success)
								{
									move_story_to_pane(dropped_story, src_pane);
								}
							}
						},
					});				
				}
			);

	
		}
	);
})(jQuery)