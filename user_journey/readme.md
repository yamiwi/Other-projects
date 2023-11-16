In this data analysis project, i developed a SQL query to extract user journey data for a specific analysis. The focus was on paying customers who made their first purchase in Q1 2023. I grouped all pages visited in a session into a single string, representing the user’s journey. This data was then included in a CSV file, along with the user’s ID, session ID, and subscription type. I also assigned aliases to the most frequently visited URLs for clarity. The final output was a comprehensive CSV file that included the user ID, session ID, subscription type, and a string representing the user’s journey. <br> 
This data is crucial for understanding the sequence of page visits leading to a purchase, providing valuable insights for business strategy and decision-making. 
<br>
Next i were tasked with analyzing user journeys of customers who purchased a product. The goal was to improve the front page flow and identify key pages.
I started by cleaning and preparing the data using Python. I created three functions to transform the data into a more analyzable state and exported the cleaned data to a CSV file.
* The first function removed sequences of repeating pages in each user journey, leaving only a single reference in place of the sequence. This helped to eliminate unnecessary repetition in the data.
* Next, i created a function to group a single user’s journey strings into one large string. This function was designed to be flexible, allowing for potential future requirements such as considering only the first 10 or last 3 sessions of a user.
* Finally, i developed a function to remove unnecessary pages from the data. This function was designed to be called upon later if needed, providing me with the flexibility to decide which pages are essential for the analysis. <br>
Also i developed several key metrics to gain insights into the behavior of purchasing customers.<br>
* Page Count: This fundamental metric counts the frequency of each page in all user journeys.
* Page Presence: Similar to ‘Page Count’, but it counts each page only once per journey, showing how often each page is part of a journey.
* Page Sequences: This metric identifies the most popular sequence of N pages in the user journeys.
* Journey Length: This straightforward metric calculates the average length of a user journey in terms of pages.
Each of these metrics was implemented as a function. 
