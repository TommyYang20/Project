//Zhijun Yang
//1658412
//p3
public class Matrix {
	
	private class Entry {
		double value;
		int column;

		Entry(double value, int column) {
			this.value = value;
			this.column = column;
		}
		public boolean equals(Object x) {
            boolean equals = false;
            Entry temp;
            if (!(x instanceof Entry)) {
                return equals;
            }
            temp = (Entry) x;
            equals = (this.column == temp.column && this.value == temp.value);
            return equals;
        }

        public String toString() {
            return ("(" + String.valueOf(column) + ", " + String.valueOf(value) + ")");
        }
    }

    private List[] rowData;
    private int size;
    private int NNZ;

    public Matrix(int index) {
        rowData = new List[index];
        size = index;
        int i = 0;
        if (i < index) {
            do {
                rowData[i] = new List();
                i++;
            } while (i < index);
        }
        NNZ = 0;
    }

    int getSize(){
    	return size;
    }

    int getNNZ(){
        return NNZ;
    }

    public boolean equals(Object oM) {
        if (!(oM instanceof Matrix)) {
            throw new RuntimeException("ERROR: equals on non-matrix");
        }
        Matrix matrixData;
        matrixData = (Matrix) oM;
        if (matrixData.getSize() == size) {
            if (matrixData.getNNZ() != NNZ) {
                return false;
            }
            int i = 0;
            if (i < size) {
                do {
                    if (rowData[i].length() != matrixData.rowData[i].length()) return false;

                    rowData[i].moveFront();
                    matrixData.rowData[i].moveFront();
                    while (rowData[i].index() != -1) {
                        if (!(rowData[i].get().equals(matrixData.rowData[i].get()))) {
                            return false;
                        }
                        rowData[i].moveNext();
                        matrixData.rowData[i].moveNext();
                    }
                    i++;
                } while (i < size);
            }
            return true;
        }

        return false;
    }

    void makeZero() {
        if (size > 1) {
            int i = 0;
            if (i < size) {
                do {
                    rowData[i].clear();
                    i++;
                } while (i < size);
            }
        }
        NNZ = 0;
    }

    Matrix copy() {
        Matrix anotherMatrix = new Matrix(size);
        int index = 0;
        if (index < size) {
            do {
                rowData[index].moveFront();
                while (rowData[index].index() != -1) {
                    Entry newEntry = new Entry(((Entry) rowData[index].get()).value, ((Entry) rowData[index].get()).column);
                    anotherMatrix.rowData[index].append(newEntry);
                    anotherMatrix.NNZ++;
                    if (anotherMatrix.NNZ == this.NNZ)
                        return anotherMatrix;
                    rowData[index].moveNext();
                }
                index++;
            } while (index < size);
        }
        return anotherMatrix;
    }

    void changeEntry(int indexOne, int innerIndex, double x) {
        if (indexOne <= 0 || indexOne > size || innerIndex > size || innerIndex <= 0 || size == 0) {
            System.err.println("ERROR: Matrix.ChangeEntry() out of bound");
            return;
        }

        double half = innerIndex / size;
        if (half < 0.5) {
            rowData[indexOne - 1].moveFront();
            if (rowData[indexOne - 1].index() != -1) {
                do {
                    if (((Entry) rowData[indexOne - 1].get()).column != innerIndex) {
                        if (((Entry) rowData[indexOne - 1].get()).column > innerIndex) {
                            if (x != 0) {
                                NNZ++;

                                Entry anotherEntry = new Entry(x, innerIndex);
                                if ((rowData[indexOne - 1].get()) == (rowData[indexOne - 1].front())) {
                                    rowData[indexOne - 1].prepend(anotherEntry);
                                } else
                                    rowData[indexOne - 1].insertBefore(anotherEntry);
                            }
                            return;
                        }
                    } else {
                        if (x != 0) {
                            ((Entry) rowData[indexOne - 1].get()).value = x;

                            return;
                        } else {
                            NNZ--;
                            boolean deleted = false;
                            if (rowData[indexOne - 1].front() != rowData[indexOne - 1].get()) {
                                if (rowData[indexOne - 1].back() != rowData[indexOne - 1].get()) {
                                    if (!deleted) {
                                        (rowData[indexOne - 1]).delete();
                                    }
                                } else {
                                    (rowData[indexOne - 1]).deleteBack();
                                }

                            } else {
                                (rowData[indexOne - 1]).deleteFront();
                            }

                            return;
                        }
                    }
                    rowData[indexOne - 1].moveNext();
                } while (rowData[indexOne - 1].index() != -1);
            }
            if (x != 0) {
                NNZ++;
                Entry newEntry = new Entry(x, innerIndex);
                rowData[indexOne - 1].append(newEntry);
            }
            return;
        }

        rowData[indexOne - 1].moveBack();
        while (rowData[indexOne - 1].index() != -1) {
            if (((Entry) rowData[indexOne - 1].get()).column == innerIndex) {
                if (x == 0) {
                    NNZ--;
                    boolean deleted = false;
                    if (rowData[indexOne - 1].front() == rowData[indexOne - 1].get()) {
                        (rowData[indexOne - 1]).deleteFront();
                        deleted = true;
                    } else if (rowData[indexOne - 1].back() == rowData[indexOne - 1].get()) {
                        (rowData[indexOne - 1]).deleteBack();
                        deleted = true;
                    } else if (!deleted) {
                        (rowData[indexOne - 1]).delete();
                    }
                    return;
                }
                ((Entry) rowData[indexOne - 1].get()).value = x;
                return;
            } else if (((Entry) rowData[indexOne - 1].get()).column < innerIndex) {
                if (x != 0) {
                    NNZ++;
                    Entry newEntry = new Entry(x, innerIndex);

                    if ((rowData[indexOne - 1].get()) == (rowData[indexOne - 1].back())) {
                        rowData[indexOne - 1].append(newEntry);
                    } else
                        rowData[indexOne - 1].insertAfter(newEntry);

                }
                return;
            }
            rowData[indexOne - 1].movePrev();
        }
        if (x != 0) {
            NNZ++;
            Entry newEntry = new Entry(x, innerIndex);
            rowData[indexOne - 1].prepend(newEntry);
        }
    }

    Matrix scalarMult(double x) {
    	if (this.getSize() != 0) {
            Matrix testMatrix = new Matrix(getSize());
            int index = 0;
            if (index >= getSize()) {
                return testMatrix;
            }
            do {
                rowData[index].moveFront();
                if (rowData[index].index() != -1) {
                    do {
                        Entry firstEntry = (Entry) rowData[index].get();
                        testMatrix.changeEntry(index + 1, firstEntry.column, firstEntry.value * x);
                        if (testMatrix.NNZ == NNZ) {
                            return testMatrix;
                        }
                        rowData[index].moveNext();
                    } while (rowData[index].index() != -1);
                }
                index++;
            } while (index < getSize());
            return testMatrix;
        } else {
            // Throwing exception will make the sure to access the line that has problem in the code in case the exception has been reached
            throw new RuntimeException("Error:  Matrices of different type applied to Matrix.scalraMult()");
        }
    }

    Matrix add(Matrix matrix) {
        if (size != matrix.getSize()) {
            throw new RuntimeException("ERROR: cannot addMatrix matrices of different sizes");
        }
        if (matrix == this) return this.copy().scalarMult(2.0);

        Matrix addMatrix = new Matrix(getSize());
        int index = 0;
        if (index < getSize()) {
            do {
                List A = new List();
                rowData[index].moveFront();
                matrix.rowData[index].moveFront();
                if (rowData[index].index() >= 0 || matrix.rowData[index].index() >= 0) {
                    do {
                        if (rowData[index].index() >= 0 && matrix.rowData[index].index() >= 0) {
                            Entry a = (Entry) rowData[index].get();
                            Entry b = (Entry) matrix.rowData[index].get();
                            if (a.column > b.column) {
                                A.append(new Entry(b.value, b.column));
                                addMatrix.NNZ++;
                                matrix.rowData[index].moveNext();
                            } else if (a.column < b.column) {
                                A.append(new Entry(a.value, a.column));
                                addMatrix.NNZ++;
                                rowData[index].moveNext();
                            } else if (a.column == b.column) {
                                if (a.value + b.value != 0) {
                                    A.append(new Entry(a.value + b.value, a.column));
                                    addMatrix.NNZ++;
                                }
                                rowData[index].moveNext();
                                matrix.rowData[index].moveNext();
                            }
                        } else if (rowData[index].index() >= 0) {
                            Entry a = (Entry) rowData[index].get();
                            A.append(new Entry(a.value, a.column));
                            addMatrix.NNZ++;
                            rowData[index].moveNext();
                        } else {
                            Entry b = (Entry) matrix.rowData[index].get();
                            A.append(new Entry((b.value), b.column));
                            addMatrix.NNZ++;
                            matrix.rowData[index].moveNext();
                        }
                    } while (rowData[index].index() >= 0 || matrix.rowData[index].index() >= 0);
                }
                addMatrix.rowData[index] = A;
                index++;
            } while (index < getSize());
        }
        return addMatrix;
    }

    Matrix sub(Matrix matrix) {
        if (size != matrix.getSize()) {
            throw new RuntimeException("ERROR: cannot perform subtraction on matrices of different sizes");
        }
        if (matrix == this) return new Matrix(getSize());

        Matrix subMatrix = new Matrix(getSize());
        int i = 0;
        if (i >= getSize()) {
            return subMatrix;
        }
        do {
            List A = new List();
            rowData[i].moveFront();
            matrix.rowData[i].moveFront();
            if (rowData[i].index() >= 0 || matrix.rowData[i].index() >= 0) {
                do {
                    if (rowData[i].index() >= 0 && matrix.rowData[i].index() >= 0) {
                        Entry a = (Entry) rowData[i].get();
                        Entry b = (Entry) matrix.rowData[i].get();
                        if (a.column > b.column) {
                            A.append(new Entry(-b.value, b.column));
                            subMatrix.NNZ++;
                            matrix.rowData[i].moveNext();
                        } else if (a.column < b.column) {
                            A.append(new Entry(a.value, a.column));
                            subMatrix.NNZ++;
                            rowData[i].moveNext();
                        } else if (a.column == b.column) {
                            if ((a.value - b.value != 0)) {
                                A.append(new Entry((a.value - b.value), a.column));
                                subMatrix.NNZ++;
                            }
                            rowData[i].moveNext();
                            matrix.rowData[i].moveNext();
                        }
                    } else if (rowData[i].index() >= 0) {
                        Entry a = (Entry) rowData[i].get();
                        A.append(new Entry(a.value, a.column));
                        subMatrix.NNZ++;
                        rowData[i].moveNext();
                    } else {
                        Entry b = (Entry) matrix.rowData[i].get();
                        A.append(new Entry((-b.value), b.column));
                        subMatrix.NNZ++;
                        matrix.rowData[i].moveNext();
                    }
                } while (rowData[i].index() >= 0 || matrix.rowData[i].index() >= 0);
            }
            subMatrix.rowData[i] = A;
            i++;
        } while (i < getSize());

        return subMatrix;
    }

    Matrix transpose(){
      Matrix matrix = new Matrix(size);

      for(int index = 0; index < size; index++) {
         rowData[index].moveFront();

         while(rowData[index].index() >= 0) {
            Entry cell = (Entry) rowData[index].get();
            int col = cell.column;
            System.out.println("matrix (i,j,val): " + (index + 1) + ", " + col + ", " + cell.value);

            matrix.changeEntry(col, index + 1, cell.value);
            rowData[index].moveNext();
         }
      }
      return matrix;
   }

      Matrix mult(Matrix matrix) {
      	if (matrix.getSize() != getSize()) {
            throw new RuntimeException("ERROR: Cannot perform multiplication on matrices of different sizes at Matrix.matrixMultiplication() ");
        }
        Matrix testMatrix = new Matrix(size);
        Matrix A = matrix.transpose();
        /*int index = 0;
        if (index < getSize()) {
            do {
                if (rowData[index].length() == 0) {
                    index++;
                    continue;
                }
                int j = 0;
                if (j < getSize()) {
                    do {
                        if (A.rowData[j].length() == 0) {
                            index++;
                            j++;
                            continue;
                        }
                        testMatrix.changeEntry(index + 1, j + 1, dot(rowData[index], A.rowData[j]));
                        j++;
                    } while (j < getSize());
                }
                index++;
            } while (index < getSize());
        }
        return testMatrix;
    }*/

    private static double dot(List A, List B) {
        A.moveFront();
        double product = 0;
        if (A.index() != -1) {
            do {
                Entry a = (Entry) A.get();
                B.moveFront();
                if (B.index() != -1) {
                    do {
                        Entry b = (Entry) B.get();
                        if (a.column == b.column) {
                            product += a.value * b.value;
                            break;
                        }
                        B.moveNext();
                    } while (B.index() != -1);
                }
                A.moveNext();
            } while (A.index() != -1);
        }
        return product;
    }

    public String toString() {
        String str = "";
        int j = 0;
        if (j >= size) {
            return str;
        }
        do {
            if (rowData[j].length() == 0) {
                j++;
                continue;
            }
            str = str + (j + 1) + ": " + rowData[j].toString() + "\n";
            j++;
        } while (j < size);
        return str;
    }
}








