//Zhijun Yang
//zyang100	
//pa3

public class Matrix{

	private class Entry{
		int column;
		double value;

		Entry(double value, int column){
			this.column = column;
			this.value = value;
		}

		public String toString(){
			return("(" + column + ", " + value + ") ");
		}

	public boolean equals(Object X){
            Entry E=(Entry)X;
            if(this.value==E.value&&this.column==E.column){
                return true;
            }else{
            return false;
            }
        }
    }

	private int NNZ;
	private List[] row;
	private int size;

	Matrix(int n){
		if (n < 1){
			throw new RuntimeException("Matrix Error: Matrix() called on size less than 1");
		}
		row = new List[n];
		size = n;
		int i = 0;
		while(i < n){
			row[i] = new List();
			i++;
		}
		NNZ = 0; 
	}

	int getSize(){
		return size;
	}

	int getNNZ(){
		return NNZ;
	}

	public boolean equals(Object x){
        boolean eq = true;
        Matrix M = (Matrix) x;
        eq = (size == M.size);
        int i = 0;
        while(i <getSize()){
            if (row[i].length()!= 0 && M.row[i].length() != 0){
                if (!(row[i].equals(M.row[i]) || this.getNNZ() == M.getNNZ())){ 
                    eq = false;
                    break;
                }
            }
            i++;
        }
        return eq;
    }

void makeZero(){
	int i = 1;
	while(i < size){
		row[i].clear();
		i++;
	}
	NNZ = 0;
}

Matrix copy(){
	Matrix temp = new Matrix(size);
	int i = 0;
	while(i < size){
		row[i].moveFront();
		while(row[i].index()!=-1){
			Entry e = (Entry) row[i].get();
			Entry newEntry = new Entry(e.value, e.column);
            temp.row[i].append(newEntry);
            temp.NNZ++;
            if(temp.NNZ == this.NNZ){
            	return temp;
            }
            row[i].moveNext();
		}
		i++;
	}
	return temp;
	
}
		
void changeEntry(int i, int j, double x){
	if((i <= 1 && i >= getSize()) || (j <= 1 && j >= getSize())){
        throw new RuntimeException("Matrix error: changeEntry() called invalid ith, jth position");
    }        
    if (row[i-1].length() == 0) {
        if (x != 0){
            Entry E = new Entry(x, j);
            row[i-1].append(E);
            NNZ++;
            }
        }else{
            row[i-1].moveFront();
            for (int rows = 1; rows <= j; rows++) {
                Entry entry = (Entry) row[i-1].get();
                if (entry.column == j) {
                    if (x == 0) {
                        row[i-1].delete();
                        NNZ--;
                        break;
                    }else{
                        entry.value = x;
                        break;
                    }
                }else if (entry.column > j){
                    if (x == 0){
                        break;
                    }else{
                        row[i-1].insertBefore(new Entry(x, j));
                        NNZ++;
                        break;
                    }
                }else{
                    row[i-1].moveNext();
                    if (row[i-1].index() == -1){
                        if (x == 0){
                            break;
                        }else{
                            row[i-1].append(new Entry(x, j));
                            NNZ++;
                            break;
                        }
                    }
                }
            }
        }
    }



Matrix scalarMult(double x){
	Matrix M = new Matrix(getSize());
	int i = 0;
	while(i < getSize()){
		row[i].moveFront();
		while(row[i].index()!=-1){
			Entry entry = (Entry)row[i].get();
			double scalarMult = x * entry.value;
			M.changeEntry(i+1, entry.column, scalarMult);
			row[i].moveNext();
		}
		i++;
	}
	return M;
}



	

Matrix sub(Matrix M){
	if(size != M.getSize()){
		throw new RuntimeException("Matrix Error: sub() called on wrong size");
	}

	if(M == this){
		return new Matrix(getSize());
	}

	Matrix subM = new Matrix(getSize());
	int i = 0;
	while (i<getSize()){
		row[i].moveFront();
		M.row[i].moveFront();
		while(row[i].index() >= 0 || M.row[i].index()>= 0){
			if(row[i].index() >= 0 && M.row[i].index() >= 0) {
			 Entry a = (Entry) row[i].get();
			 Entry b = (Entry) M.row[i].get();
				if(a.column == b.column){
					if((a.value - b.value!= 0)) {
						subM.changeEntry(i+1, a.column, (a.value-b.value));
						row[i].moveNext();
						M.row[i].moveNext();
					}else{
					row[i].moveNext();
					M.row[i].moveNext();
					}
				}else if (a.column > b.column) {
					subM.changeEntry(i+1, b.column, -b.value);
					M.row[i].moveNext();
				}else if (a.column < b.column){
					subM.changeEntry(i+1, a.column, a.value);
					row[i].moveNext();	
				}

			}else if (row[i].index()>=0) {
					Entry a = (Entry) row[i].get();
					subM.changeEntry(i+1, a.column, a.value);
					row[i].moveNext();
			}else if (M.row[i].index() >=0){
					Entry b = (Entry) M.row[i].get();
					subM.changeEntry(i+1, b.column, b.value);
					M.row[i].moveNext();
				}
			
			}
			i++;
		}
		return subM;
	
}


Matrix transpose(){
	Matrix M = new Matrix(size);
	int i = 0;
	while(i < size){
		row[i].moveFront();
		while(row[i].index() != -1){
			Entry entry = (Entry)row[i].get();
			int col = entry.column;
			M.changeEntry(col, i+1, entry.value);
			row[i].moveNext();
		}
		i++;
	}
	return M;
}

Matrix add(Matrix M){
	if(size != M.getSize()){
		throw new RuntimeException("Matrix Error: add() called on wrong size");
	}

	if(M == this){
		return this.copy().scalarMult(2.0);
	}
	int i = 0;
	Matrix addM= new Matrix(getSize());

	while(i< getSize()){
		row[i].moveFront();
		M.row[i].moveFront();
		while(row[i].index() >= 0 || M.row[i].index()>=0){
			if(row[i].index() >= 0 && M.row[i].index()>=0){
			Entry a = (Entry) row[i].get();
			Entry b = (Entry) M.row[i].get();
			if(a.column == b.column) {
				if(a.value + b.value != 0) {
					addM.changeEntry(i+1, a.column, (a.value + b.value));
					row[i].moveNext();
					M.row[i].moveNext();
				}else{
					row[i].moveNext();
					M.row[i].moveNext();
					}
				}
				else if(a.column > b.column) {
					addM.changeEntry(i+1, b.column, b.value);
					M.row[i].moveNext();
				}
				else if( a.column < b.column) {
					addM.changeEntry(i+1, a.column, a.value);
					row[i].moveNext();
				}
			}

			else if(row[i].index()>=0){
				Entry a = (Entry) row[i].get();
				addM.changeEntry(i+1, a.column, a.value);
				row[i].moveNext();
			}
			else if(M.row[i].index()>=0){
				Entry b = (Entry) M.row[i].get();
				addM.changeEntry(i+1, b.column, b.value);
				M.row[i].moveNext();
			}
		}
			i++;
		}
		return addM;
	}

	Matrix mult(Matrix M) {
		if(M.getSize() != getSize()) {
			throw new RuntimeException("Matrix Error: mult() called on wrong size");
		}
		Matrix temp1 = new Matrix(size);
		Matrix temp2 = M.transpose();
		for(int i = 0; i < getSize();i++) {
			if(row[i].length() == 0 ){
				continue;
			} 
			for(int j = 0 ; j < getSize(); j++) {
				if(temp2.row[j].length() == 0){
				 	continue;
				}
				temp1.changeEntry(i +1, j +1, dot(row[i],temp2.row[j]));
			}
		}
		return temp1;
	}




 public String toString() {        
        StringBuffer sb = new StringBuffer();

        for(int i = 0; i < getSize(); i++){
            if (row[i].length() == 0){
            	continue;
            }
                sb.append((i+1) + ": " + row[i] + "\n");
            }
            return new String(sb);
    }


private static double dot(List A, List B){
	double product = 0.0;
	A.moveFront();
	while(A.index()!=-1){
		Entry a = (Entry) A.get();
		B.moveFront();
		while(B.index()!=-1){
			Entry b = (Entry) B.get();
			if(a.column == b.column){
				product += a.value * b.value;
				break;
			}
				B.moveNext();
			}
			A.moveNext();
		}
		return product;
	}
}



