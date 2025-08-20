import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import fs from 'fs';

// Mock dependencies
vi.mock('wasmoon', () => ({
  LuaFactory: vi.fn(() => ({
    createEngine: vi.fn(() => ({
      doString: vi.fn(),
      global: {
        get: vi.fn(),
        close: vi.fn()
      }
    })),
    mountFile: vi.fn()
  }))
}));

vi.mock('fs');

describe('generate-lua', () => {
  const mockProcess = {
    stdin: {
      setEncoding: vi.fn(),
      on: vi.fn()
    },
    exit: vi.fn()
  };

  beforeEach(() => {
    vi.clearAllMocks();
    // @ts-ignore
    global.process = mockProcess;
    vi.mocked(fs.readFileSync).mockReturnValue('mock lua content');
  });

  afterEach(() => {
    vi.restoreAllMocks();
  });

  it('sets up stdin encoding', async () => {
    // Import the module to trigger the setup
    await import('./generate-lua');
    
    expect(mockProcess.stdin.setEncoding).toHaveBeenCalledWith('utf8');
    expect(mockProcess.stdin.on).toHaveBeenCalledWith('data', expect.any(Function));
  });

  it('mounts required lua files', async () => {
    await import('./generate-lua');
    
    const { LuaFactory } = await import('wasmoon');
    const mockFactory = new LuaFactory();
    
    // Trigger the data event
    const dataHandler = vi.mocked(mockProcess.stdin.on).mock.calls[0][1];
    await dataHandler('{"test": "data"}');

    expect(mockFactory.mountFile).toHaveBeenCalledTimes(5);
    expect(mockFactory.mountFile).toHaveBeenCalledWith('LibDeflate.lua', 'mock lua content');
    expect(mockFactory.mountFile).toHaveBeenCalledWith('LibSerialize.lua', 'mock lua content');
    expect(mockFactory.mountFile).toHaveBeenCalledWith('dkjson.lua', 'mock lua content');
    expect(mockFactory.mountFile).toHaveBeenCalledWith('inspect.lua', 'mock lua content');
    expect(mockFactory.mountFile).toHaveBeenCalledWith('encode.lua', 'mock lua content');
  });

  it('uses generateLuaTable when available', async () => {
    await import('./generate-lua');
    
    const { LuaFactory } = await import('wasmoon');
    const mockFactory = new LuaFactory();
    const mockEngine = await mockFactory.createEngine();
    const mockGenerateLuaTable = vi.fn().mockReturnValue('lua table output');
    
    vi.mocked(mockEngine.global.get).mockReturnValue(mockGenerateLuaTable);
    
    const consoleSpy = vi.spyOn(console, 'log').mockImplementation();
    
    // Trigger the data event
    const dataHandler = vi.mocked(mockProcess.stdin.on).mock.calls[0][1];
    await dataHandler('{"test": "data"}');

    expect(mockEngine.global.get).toHaveBeenCalledWith('generateLuaTable');
    expect(mockGenerateLuaTable).toHaveBeenCalledWith('{"test": "data"}');
    expect(consoleSpy).toHaveBeenCalledWith('lua table output');
    expect(mockEngine.global.close).toHaveBeenCalled();
    expect(mockProcess.exit).toHaveBeenCalled();
    
    consoleSpy.mockRestore();
  });

  it('falls back to inspect when generateLuaTable not available', async () => {
    await import('./generate-lua');
    
    const { LuaFactory } = await import('wasmoon');
    const mockFactory = new LuaFactory();
    const mockEngine = await mockFactory.createEngine();
    const mockJson = { decode: vi.fn().mockReturnValue({ parsed: 'data' }) };
    const mockInspect = vi.fn().mockReturnValue('inspected output');
    
    vi.mocked(mockEngine.global.get)
      .mockReturnValueOnce(null) // generateLuaTable not available
      .mockReturnValueOnce(mockJson) // json
      .mockReturnValueOnce(mockInspect); // inspect
    
    const consoleSpy = vi.spyOn(console, 'log').mockImplementation();
    
    // Trigger the data event
    const dataHandler = vi.mocked(mockProcess.stdin.on).mock.calls[0][1];
    await dataHandler('{"test": "data"}');

    expect(mockEngine.global.get).toHaveBeenCalledWith('generateLuaTable');
    expect(mockEngine.global.get).toHaveBeenCalledWith('json');
    expect(mockEngine.global.get).toHaveBeenCalledWith('inspect');
    expect(mockJson.decode).toHaveBeenCalledWith('{"test": "data"}');
    expect(mockInspect).toHaveBeenCalledWith({ parsed: 'data' });
    expect(consoleSpy).toHaveBeenCalledWith('inspected output');
    expect(mockEngine.global.close).toHaveBeenCalled();
    expect(mockProcess.exit).toHaveBeenCalled();
    
    consoleSpy.mockRestore();
  });

  it('processes input without trimming', async () => {
    await import('./generate-lua');
    
    const { LuaFactory } = await import('wasmoon');
    const mockFactory = new LuaFactory();
    const mockEngine = await mockFactory.createEngine();
    const mockGenerateLuaTable = vi.fn().mockReturnValue('output');
    
    vi.mocked(mockEngine.global.get).mockReturnValue(mockGenerateLuaTable);
    vi.spyOn(console, 'log').mockImplementation();
    
    // Trigger the data event with whitespace (should NOT be trimmed)
    const dataHandler = vi.mocked(mockProcess.stdin.on).mock.calls[0][1];
    await dataHandler('  {"test": "data"}  \n');

    expect(mockGenerateLuaTable).toHaveBeenCalledWith('  {"test": "data"}  \n');
  });

  it('loads index.lua file', async () => {
    await import('./generate-lua');
    
    const { LuaFactory } = await import('wasmoon');
    const mockFactory = new LuaFactory();
    const mockEngine = await mockFactory.createEngine();
    
    vi.mocked(mockEngine.global.get).mockReturnValue(vi.fn().mockReturnValue('output'));
    
    // Trigger the data event
    const dataHandler = vi.mocked(mockProcess.stdin.on).mock.calls[0][1];
    await dataHandler('{}');

    expect(fs.readFileSync).toHaveBeenCalledWith('./public/lua/index.lua', 'utf8');
    expect(mockEngine.doString).toHaveBeenCalledWith('mock lua content');
  });
});