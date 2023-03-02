# NewsBite

NewsBite is an application that helps you follow the latest news through Bites, groups that highlight the top 10 common words in the titles and descriptions of the 100 newest articles for a certain topic.

![image](https://user-images.githubusercontent.com/13724957/222465645-fe5ad836-814e-4aa4-b9e4-a7f2dee9e111.png)

## Disclaimer

This was developed as a personal experiment, and as such has no concept of multiple users.

Evaluated as an experiment, the article results of Bites are at times disappointing, returning words that do not paint a meaningful summary of the current news.

- If future development is to occur, it would be beneficial to check against more than 100 articles and develop a more extensive list of words to filter out.

## Starting the Application

To start the application:

- Install Elixir and Phoenix
- Install dependencies with `mix deps.get`
- Start Phoenix endpoint with `mix phx.server`
- If running locally, in `local.exs` replace news_api_key with your own api key from [newsapi.org](https://newsapi.org/)

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
