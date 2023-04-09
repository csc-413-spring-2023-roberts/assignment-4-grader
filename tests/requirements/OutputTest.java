package tests.requirements;

import static org.junit.jupiter.api.Assertions.assertEquals;

import java.io.BufferedWriter;
import java.io.ByteArrayOutputStream;
import java.io.FileWriter;
import java.io.PrintStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import ast.AST;
import parser.Parser;
import visitor.PrintVisitor;

public class OutputTest {
  private final PrintStream standardOut = System.out;
  private final ByteArrayOutputStream outputStreamCaptor = new ByteArrayOutputStream();

  @Before
  public void setUp() {
    System.setOut(new PrintStream(outputStreamCaptor));
    AST.NodeCount = 0;
  }

  @After
  public void tearDown() {
    System.setOut(standardOut);
  }

  @Test
  public void testOutput() throws Exception {
    Path temp = Files.createTempFile("spring-2023", ".x");
    String absolutePath = temp.toString();

    BufferedWriter writer = new BufferedWriter(new FileWriter(absolutePath));
    writer.write(TEST_FILE);
    writer.close();

    Parser parser = new Parser(absolutePath);
    AST t = parser.execute();

    System.out.println(parser.getLex());

    System.out.println("---------------AST-------------");
    PrintVisitor pv = new PrintVisitor();
    t.accept(pv);

    outputStreamCaptor.flush();
    String result = outputStreamCaptor.toString();

    String[] outputLines = result.split(System.lineSeparator());
    String[] expectLines = EXPECTED_OUTPUT.split(System.lineSeparator());

    for (int i = 0; i < outputLines.length && i < expectLines.length; i++) {
      // This is hacky af but it seems to get rid of whitespace mismatches, and I'm
      // tired of looking at it
      // for (int j = 0; j < expectLines[i].length(); j++) {
      // assertEquals(expectLines[i].charAt(j), outputLines[i].charAt(j));
      // }

      assertEquals(expectLines[i], outputLines[i]);
    }
  }

  private static final String TEST_FILE = String.join(
      System.lineSeparator(),
      List.of(
          "program {",
          "  // TYPE -> 'string'",
          "  // TYPE -> 'hex",
          "  // F -> <string>",
          "  // F -> <hex>",
          "  int result string s string t hex h hex i",
          "",
          "  string fn(hex h) {",
          "    return @wave@",
          "  }",
          "",
          "  s = @test string@",
          "  h = 0xabcdef",
          "",
          "  // E -> SE '>' SE",
          "  result = s > t",
          "  // E -> SE '>=' SE",
          "  result = h >= i",
          "  // T -> T '%' F",
          "  result = 7 % 2 == 1",
          "",
          "  // S -> 'if' E 'then' BLOCK (without else)",
          "  if(result) then {",
          "    result = write(1)",
          "  }",
          "",
          "  // S -> 'unless' E 'then' BLOCK",
          "  unless(result) then {",
          "    result = write(42)",
          "  }",
          "",
          "  // S -> 'select' NAME SELECT_BLOCK",
          "  // SELECT_BLOCK -> '{' SELECTOR+ '}'",
          "  // SELECTOR -> '[' E ']' '->' BLOCK",
          "  select i {",
          "    [1 == 1] -> { result = write(7) }",
          "    [1 == 0] -> { result = write(9) }",
          "  }",
          "}"));

  private static final String EXPECTED_OUTPUT = String.join(
      System.lineSeparator(),
      List.of(
          "  1: program {",
          "  2:   // TYPE -> 'string'",
          "  3:   // TYPE -> 'hex",
          "  4:   // F -> <string>",
          "  5:   // F -> <hex>",
          "  6:   int result string s string t hex h hex i",
          "  7:",
          "  8:   string fn(hex h) {",
          "  9:     return @wave@",
          " 10:   }",
          " 11:",
          " 12:   s = @test string@",
          " 13:   h = 0xabcdef",
          " 14:",
          " 15:   // E -> SE '>' SE",
          " 16:   result = s > t",
          " 17:   // E -> SE '>=' SE",
          " 18:   result = h >= i",
          " 19:   // T -> T '%' F",
          " 20:   result = 7 % 2 == 1",
          " 21:",
          " 22:   // S -> 'if' E 'then' BLOCK (without else)",
          " 23:   if(result) then {",
          " 24:     result = write(1)",
          " 25:   }",
          " 26:",
          " 27:   // S -> 'unless' E 'then' BLOCK",
          " 28:   unless(result) then {",
          " 29:     result = write(42)",
          " 30:   }",
          " 31:",
          " 32:   // S -> 'select' NAME SELECT_BLOCK",
          " 33:   // SELECT_BLOCK -> '{' SELECTOR+ '}'",
          " 34:   // SELECTOR -> '[' E ']' '->' BLOCK",
          " 35:   select i {",
          " 36:     [1 == 1] -> { result = write(7) }",
          " 37:     [1 == 0] -> { result = write(9) }",
          " 38:   }",
          " 39: }",
          "---------------AST-------------",
          "1:  Program",
          "2:    Block",
          "5:      Decl",
          "3:        IntType",
          "4:        Id: result",
          "8:      Decl",
          "6:        StringType",
          "7:        Id: s",
          "11:     Decl",
          "9:        StringType",
          "10:       Id: t",
          "14:     Decl",
          "12:       HexType",
          "13:       Id: h",
          "17:     Decl",
          "15:       HexType",
          "16:       Id: i",
          "20:     FunctionDecl",
          "18:       StringType",
          "19:       Id: fn",
          "21:       Formals",
          "24:         Decl",
          "22:           HexType",
          "23:           Id: h",
          "25:       Block",
          "26:         Return",
          "27:           String: wave",
          "29:     Assign",
          "28:       Id: s",
          "30:       String: test string",
          "32:     Assign",
          "31:       Id: h",
          "33:       Hex: 0xabcdef",
          "35:     Assign",
          "34:       Id: result",
          "37:       RelOp: >",
          "36:         Id: s",
          "38:         Id: t",
          "40:     Assign",
          "39:       Id: result",
          "42:       RelOp: >=",
          "41:         Id: h",
          "43:         Id: i",
          "45:     Assign",
          "44:       Id: result",
          "49:       RelOp: ==",
          "47:         MultOp: %",
          "46:           Int: 7",
          "48:           Int: 2",
          "50:         Int: 1",
          "51:     If",
          "52:       Id: result",
          "53:       Block",
          "55:         Assign",
          "54:           Id: result",
          "57:           Call",
          "56:             Id: write",
          "58:             Int: 1",
          "59:     Unless",
          "60:       Id: result",
          "61:       Block",
          "63:         Assign",
          "62:           Id: result",
          "65:           Call",
          "64:             Id: write",
          "66:             Int: 42",
          "67:     Select",
          "68:       Id: i",
          "69:       SelectBlock",
          "70:         Selector",
          "72:           RelOp: ==",
          "71:             Int: 1",
          "73:             Int: 1",
          "74:           Block",
          "76:             Assign",
          "75:               Id: result",
          "78:               Call",
          "77:                 Id: write",
          "79:                 Int: 7",
          "80:         Selector",
          "82:           RelOp: ==",
          "81:             Int: 1",
          "83:             Int: 0",
          "84:           Block",
          "86:             Assign",
          "85:               Id: result",
          "88:               Call",
          "87:                 Id: write",
          "89:                 Int: 9"));
}
