 
 module Uni_Chain::UniChain {    
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::tx_context::{Self,UID}
    struct Student has key,store {
        name: UID;
        university: string;
        documents: vector<string>;
        grades: vector<u8>;
    }

    struct UniChain has key {
        universities: map<string, map<u8, Student>>;
        suiCoinBalances: map<u8, u64>;
    }

    public fun init(): R#Self.UniChain {
        return R#Self.UniChain {
            universities: empty,
            suiCoinBalances: empty
        };
    }

    public fun registerStudent(chain: &R#Self.UniChain, universityId: string, studentId: u8, name: string, university: string) {
        if !chain.universities.contains(universityId) {
            chain.universities[universityId] = empty;
        }
        
        chain.universities[universityId][studentId] = Student {
            name: name,
            university: university,
            documents: empty,
            grades: empty
        };
        
        chain.suiCoinBalances[studentId] = 0;
    }

    public fun updateStudent(chain: &R#Self.UniChain, universityId: string, studentId: u8, name: string, university: string) {
        assert(chain.universities.contains(universityId), 1, 108); // universite bulunamadi
        assert(chain.universities[universityId].contains(studentId), 1, 101); // ogrenci bulunamadi

        chain.universities[universityId][studentId] = Student {
            name: name,
            university: university,
            documents: chain.universities[universityId][studentId].documents,
            grades: chain.universities[universityId][studentId].grades
        };
    }

    public fun verifyIdentity(chain: &R#Self.UniChain, universityId: string, studentId: u8): bool {
        chain.universities.contains(universityId) &&
        chain.universities[universityId].contains(studentId);
    }

    public fun storeDocument(chain: &R#Self.UniChain, universityId: string, studentId: u8, document: string) {
        assert(chain.universities.contains(universityId), 1, 108); // Üniversite bulunamadı
        assert(chain.universities[universityId].contains(studentId), 1, 102); // Öğrenci bulunamadı

        chain.universities[universityId][studentId].documents.push_back(document);
    }

    public fun recordGrade(chain: &R#Self.UniChain, universityId: string, studentId: u8, grade: u8) {
        assert(chain.universities.contains(universityId), 1, 108); // Üniversite bulunamadı
        assert(chain.universities[universityId].contains(studentId), 1, 105); // Öğrenci bulunamadı

        chain.universities[universityId][studentId].grades.push_back(grade);
    }

    public fun getSuiCoinBalance(chain: &R#Self.UniChain, studentId: u8): u64 {
        chain.suiCoinBalances[studentId];
    }

    public fun awardSuiCoin(chain: &R#Self.UniChain, universityId: string, studentId: u8, amount: u64) {
        assert(chain.universities.contains(universityId), 1, 108); // Üniversite bulunamadı
        assert(chain.universities[universityId].contains(studentId), 1, 104); // Öğrenci bulunamadı

        let grades = chain.universities[universityId][studentId].grades;
        let totalGrade: u8 = grades.iter().fold(0, |acc, grade| acc + grade);
        let averageGrade = totalGrade as u64 / grades.len() as u64;

        // Not ortalaması 3 ve üzeri ise Sui Coin ödülü ver
        if averageGrade >= 3 {
            // Ödeme fonksiyonunu çağır
            paySuiCoin(chain, studentId, amount);
        }
    }

    public fun paySuiCoin(chain: &R#Self.UniChain, recipient: u8, amount: u64) {
        assert(chain.suiCoinBalances[recipient] + amount >= chain.suiCoinBalances[recipient], 2, 107); // Bakiye aşımı

        chain.suiCoinBalances[recipient] += amount;
    }
}
