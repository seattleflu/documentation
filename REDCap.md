- [Enable DETs for a project](#enable-dets-for-a-project)
- [Find event ID for an event name](#find-event-id-for-an-event-name)

## Enable DETs for a project

Within the REDCap project, go to Project Setup.
Find and click the Additional Customizations button.
Scroll to the bottom of the modal, and find the Data Entry Trigger section.


## Find event ID for an event name

There is no official REDCap API for retrieving an event ID, but this event ID is required for generating deep links to specific instance of forms within REDCap.

To find the event ID, you can look at the `event_id` param in the URL of a form from your target arm and event.
If there are no forms for the arm or event you're targeting, then with a little hacking, you can retrieve the event ID in the following way:
1. From the home page of your target REDCap project, under **Project Home and Design**, click on **Project Setup**.
2. Then, under **Define your events and designate instruments for them**, click `Define my events`.
3. In your browser console, run the following JavaScript snippet:
    ```js
    edit_links = document.querySelectorAll("a[onclick^=beginEdit]")
    parse_onclick = a =>
        a.getAttribute("onclick")
    .match(/beginEdit\("(?<arm>\d+)","(?<event_id>\d+)"\)/)
    .groups;
    console.table(
    Array.from(edit_links).map(a => ({
        name: a.parentElement.parentElement.querySelector(".evt_name").textContent,
        ...parse_onclick(a)
    }))
    )
    ```
The resulting table detials the `event_id` for each event defined in the current tab's arm.
Click through the other tabs to see `event_ids` for other project arms.
