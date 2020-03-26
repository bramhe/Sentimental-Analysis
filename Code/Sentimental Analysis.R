if (!require("pacman")) install.packages("pacman")
pacman::p_load(sentimentr, dplyr, magrittr)

# Checking for a random text
mytext <- c(
  'Be strong, and be positive, and you will win over all challenges',
  'If you remain worried, then may be it wil start affecting your thoughts',
  'Idea is to stay optimistic during the time of crisis'
)

mytext <- get_sentences(mytext)
sentiment(mytext)


# To aggregate by element (column cell or vector element) use sentiment_by with by = NULL.
mytext <- get_sentences(mytext)
sentiment_by(mytext)


# To aggregate by grouping variables use sentiment_by using the by argument.
# Checking presidential database for debates in 2012
(out <- with(
  presidential_debates_2012, 
  sentiment_by(
    get_sentences(dialogue), 
    list(person, time)
  )
))


# Tidy Approach
library(magrittr)
library(dplyr)

presidential_debates_2012 %>%
  get_sentences() %$%
  sentiment_by(dialogue, list(person, time))



## Plotting

# Plotting at Aggregated Sentiment
plot(out)


# Plotting at the Sentence Level
plot(uncombine(out))


# Making and Updating Dictionaries
set.seed(10)

key <- data.frame(
  words = sample(letters),
  polarity = rnorm(26),
  stringsAsFactors = FALSE
)

# sentimentr provides the is_key function to test if a table is a key.
is_key(key)

# coerce key to a dictionary that sentimentr can use
mykey <- as_key(key)

# check that mykey is a usable dictionary
is_key(mykey)

# Use the key
sentiment_by("I am a human.", polarity_dt = mykey)
mykey[c("a", "b")][[2]]


mykey_dropped <- update_key(mykey, drop = c("a", "h"))
nrow(mykey_dropped)

sentiment_by("I am a human.", polarity_dt = mykey_dropped)

mykey_added <- update_key(mykey, x = data.frame(x = c("dog", "cat"), y = c(1, -1)))

nrow(mykey_added)
sentiment("I am a human. The dog.  The cat", polarity_dt = mykey_added)
