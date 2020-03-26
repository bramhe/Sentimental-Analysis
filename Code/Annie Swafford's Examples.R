if (!require("pacman")) install.packages("pacman")
pacman::p_load_gh("trinker/sentimentr", "trinker/stansent", "sfeuerriegel/SentimentAnalysis", "wrathematics/meanr")
pacman::p_load(syuzhet, qdap, microbenchmark, RSentiment)

# Run for an example text
ase <- c(
  "I haven't been sad in a long time.",
  "I am extremely happy today.",
  "It's a good day.",
  "But suddenly I'm only a little bit happy.",
  "Then I'm not happy at all.",
  "In fact, I am now the least happy person on the planet.",
  "There is no happiness left in me.",
  "Wait, it's returned!",
  "I don't feel so bad after all!"
)

syuzhet <- setNames(as.data.frame(lapply(c("syuzhet", "bing", "afinn", "nrc"),
                                         function(x) get_sentiment(ase, method=x))), c("jockers", "bing", "afinn", "nrc"))

SentimentAnalysis <- apply(analyzeSentiment(ase)[c('SentimentGI', 'SentimentLM', 'SentimentQDAP') ], 2, round, 2)
colnames(SentimentAnalysis) <- gsub('^Sentiment', "SA_", colnames(SentimentAnalysis))

left_just(data.frame(
  stanford = sentiment_stanford(ase)[["sentiment"]],
  sentimentr_jockers_rinker = round(sentiment(ase, question.weight = 0)[["sentiment"]], 2),
  sentimentr_jockers = round(sentiment(ase, lexicon::hash_sentiment_jockers, question.weight = 0)[["sentiment"]], 2),    
  sentimentr_huliu = round(sentiment(ase, lexicon::hash_sentiment_huliu, question.weight = 0)[["sentiment"]], 2),    
  sentimentr_sentiword = round(sentiment(ase, lexicon::hash_sentiment_sentiword, question.weight = 0)[["sentiment"]], 2),    
  RSentiment = calculate_score(ase), 
  SentimentAnalysis,
  meanr = score(ase)[['score']],
  syuzhet,
  sentences = ase,
  stringsAsFactors = FALSE
), "sentences")


ase_100 <- rep(ase, 100)

stanford <- function() {sentiment_stanford(ase_100)}

sentimentr_jockers_rinker <- function() sentiment(ase_100, lexicon::hash_sentiment_jockers_rinker)
sentimentr_jockers <- function() sentiment(ase_100, lexicon::hash_sentiment_jockers)
sentimentr_huliu <- function() sentiment(ase_100, lexicon::hash_sentiment_huliu)
sentimentr_sentiword <- function() sentiment(ase_100, lexicon::hash_sentiment_sentiword) 

RSentiment <- function() calculate_score(ase_100) 

SentimentAnalysis <- function() analyzeSentiment(ase_100)

meanr <- function() score(ase_100)

syuzhet_jockers <- function() get_sentiment(ase_100, method="syuzhet")
syuzhet_binn <- function() get_sentiment(ase_100, method="bing")
syuzhet_nrc <- function() get_sentiment(ase_100, method="nrc")
syuzhet_afinn <- function() get_sentiment(ase_100, method="afinn")

microbenchmark(
  stanford(),
  sentimentr_jockers_rinker(),
  sentimentr_jockers(),
  sentimentr_huliu(),
  sentimentr_sentiword(),
  #RSentiment(), 
  SentimentAnalysis(),
  syuzhet_jockers(),
  syuzhet_binn(), 
  syuzhet_nrc(),
  syuzhet_afinn(),
  meanr(),
  times = 3
)

library(magrittr)
library(dplyr)
set.seed(2)

hu_liu_cannon_reviews %>%
  filter(review_id %in% sample(unique(review_id), 3)) %>%
  mutate(review = get_sentences(text)) %$%
  sentiment_by(review, review_id) %>%
  highlight()
