import QuartzCore
import Testing
@testable import CanvaClassifier
import ZTronSymbolsClassifier

struct CanvaClassifierTests {

    @Test func kfcvExample() async throws {
        let classifier = Classifier<Alphabet>(samplelimit: Int.max - 1)
        var altAlphabetTrainingSet: [Alphabet: [StrokeSample]] = [:]

        
        for letter in UppercaseAlphabetTraining.trainingData.keys {
            let examples = UppercaseAlphabetTraining.trainingData[letter]!
            
            print("\(letter.rawValue): \(examples.count)")
            altAlphabetTrainingSet[letter] = []
            for example in examples {
                altAlphabetTrainingSet[letter]?.append(StrokeSample(strokes: example))
            }
        }

                
        let metrics = classifier.kFoldCrossValidate(k: 10, from: altAlphabetTrainingSet)
        
        for `class` in metrics.keys {
            if let metricsForClass = metrics[`class`] {
                print("=====\(String(describing: `class`))=======")
                print(metricsForClass.getMeanPrecision())
                print(metricsForClass.getMeanRecall())
            }
        }
    }
}


extension StrokeSample: @retroactive Equatable {
    public static func == (lhs: StrokeSample, rhs: StrokeSample) -> Bool {
        return abs(StrokeSample.distance(lhs, rhs)) < sqrt(1.ulp)
    }
}
