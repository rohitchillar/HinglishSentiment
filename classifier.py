import csv
import nltk.classify.util
from nltk.classify import NaiveBayesClassifier
from nltk.corpus import movie_reviews

def word_feats(words):
    return dict([(word, True) for word in words])

neg_feat = []
pos_feat = []
neutral_feat = []
with open('initial_data.csv', 'rb') as csvfile:
	spamreader = csv.reader(csvfile, delimiter=',')
	for row in spamreader:
		if row[1] != "":
			if int(row[1]) == 0:
				neutral_feat.append((word_feats(row[0].split()), 'neutral'))
			if int(row[1]) == 1:
				pos_feat.append((word_feats(row[0].split()), 'pos'))
			if int(row[1]) == 2:
				neg_feat.append((word_feats(row[0].split()), 'neg'))

print len(neg_feat)
print len(pos_feat)
print len(neutral_feat)

negcutoff = len(neg_feat)*8/10
poscutoff = len(pos_feat)*8/10
neutralcutoff = len(neutral_feat)*8/10

trainfeats = neg_feat[:negcutoff] + pos_feat[:poscutoff] + neutral_feat[:neutralcutoff]
testfeats = neg_feat[negcutoff:] + pos_feat[poscutoff:] + neutral_feat[neutralcutoff:]
print 'train on %d instances, test on %d instances' % (len(trainfeats), len(testfeats))
 
classifier = NaiveBayesClassifier.train(trainfeats)
print 'accuracy:', nltk.classify.util.accuracy(classifier, testfeats)
classifier.show_most_informative_features()